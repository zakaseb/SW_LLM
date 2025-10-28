import { initApiPassthrough } from "langgraph-nextjs-api-passthrough";
import {
  GITHUB_TOKEN_COOKIE,
  GITHUB_INSTALLATION_ID_COOKIE,
  GITHUB_INSTALLATION_TOKEN_COOKIE,
  GITHUB_INSTALLATION_NAME,
  GITHUB_INSTALLATION_ID,
  GITHUB_USER_ID_HEADER,
  GITHUB_USER_LOGIN_HEADER,
} from "@open-swe/shared/constants";
import {
  getGitHubInstallationTokenOrThrow,
  getInstallationNameFromReq,
  getGitHubAccessTokenOrThrow,
} from "./utils";
import { encryptSecret } from "@open-swe/shared/crypto";
import { verifyGithubUser } from "@open-swe/shared/github/verify-user";

// This file acts as a proxy for requests to your LangGraph server.
// Read the [Going to Production](https://github.com/langchain-ai/agent-chat-ui?tab=readme-ov-file#going-to-production) section for more information.

export const { GET, POST, PUT, PATCH, DELETE, OPTIONS, runtime } =
  initApiPassthrough({
    apiUrl: process.env.LANGGRAPH_API_URL ?? "http://localhost:2024",
    runtime: "edge", // default
    disableWarningLog: true,
    bodyParameters: async (req, body) => {
      const encryptionKey = process.env.SECRETS_ENCRYPTION_KEY;
      if (!encryptionKey) {
        throw new Error(
          "SECRETS_ENCRYPTION_KEY environment variable is required",
        );
      }

      // Handle API key encryption
      if (body.config?.configurable && "apiKeys" in body.config.configurable) {
        const apiKeys = body.config.configurable.apiKeys;
        const encryptedApiKeys: Record<string, unknown> = {};

        // Encrypt each field in the apiKeys object
        for (const [key, value] of Object.entries(apiKeys)) {
          if (typeof value === "string" && value.trim() !== "") {
            encryptedApiKeys[key] = encryptSecret(value, encryptionKey);
          } else {
            encryptedApiKeys[key] = value;
          }
        }

        // Update the body with encrypted apiKeys
        body.config.configurable.apiKeys = encryptedApiKeys;
      }

      // Add user identity to config.configurable for internal thread creation
      if (body.config?.configurable) {
        const plainAccessToken = req.cookies.get(GITHUB_TOKEN_COOKIE)?.value ?? "";
        if (plainAccessToken) {
          try {
            const user = await verifyGithubUser(plainAccessToken);
            if (user) {
              body.config.configurable[GITHUB_USER_ID_HEADER] = user.id.toString();
              body.config.configurable[GITHUB_USER_LOGIN_HEADER] = user.login;
            }
          } catch (error) {
            // If user verification fails here, it will fail in headers() too
            // so we can silently skip adding user identity to config
          }
        }
      }

      return body;
    },
    headers: async (req) => {
      const encryptionKey = process.env.SECRETS_ENCRYPTION_KEY;
      if (!encryptionKey) {
        throw new Error(
          "SECRETS_ENCRYPTION_KEY environment variable is required",
        );
      }
      const installationIdCookie = req.cookies.get(
        GITHUB_INSTALLATION_ID_COOKIE,
      )?.value;

      if (!installationIdCookie) {
        throw new Error(
          "No GitHub installation ID found. GitHub App must be installed first.",
        );
      }

      const plainAccessToken = req.cookies.get(GITHUB_TOKEN_COOKIE)?.value ?? "";
      if (!plainAccessToken) {
        throw new Error(
          "No GitHub access token found. User must authenticate first.",
        );
      }
      
      const [installationToken, installationName, user] = await Promise.all([
        getGitHubInstallationTokenOrThrow(installationIdCookie, encryptionKey),
        getInstallationNameFromReq(req.clone(), installationIdCookie),
        verifyGithubUser(plainAccessToken),
      ]);

      if (!user) {
        throw new Error("Failed to verify GitHub user");
      }

      return {
        [GITHUB_TOKEN_COOKIE]: getGitHubAccessTokenOrThrow(req, encryptionKey),
        [GITHUB_INSTALLATION_TOKEN_COOKIE]: installationToken,
        [GITHUB_INSTALLATION_NAME]: installationName,
        [GITHUB_INSTALLATION_ID]: installationIdCookie,
        [GITHUB_USER_ID_HEADER]: user.id.toString(),
        [GITHUB_USER_LOGIN_HEADER]: user.login,
      };
    },
  });
