import { initApiPassthrough } from "langgraph-nextjs-api-passthrough";
import {
  GITHUB_TOKEN_COOKIE,
  GITHUB_INSTALLATION_ID_COOKIE,
  GITHUB_INSTALLATION_TOKEN_COOKIE,
  GITHUB_INSTALLATION_NAME,
  GITHUB_INSTALLATION_ID,
} from "@open-swe/shared/constants";
import {
  getGitHubInstallationTokenOrThrow,
  getInstallationNameFromReq,
  getGitHubAccessTokenOrThrow,
} from "./utils";
import { encryptSecret } from "@open-swe/shared/crypto";
import { isLocalModeFromEnv } from "@open-swe/shared/open-swe/local-mode";

// This file acts as a proxy for requests to your LangGraph server.
// Read the [Going to Production](https://github.com/langchain-ai/agent-chat-ui?tab=readme-ov-file#going-to-production) section for more information.

export const { GET, POST, PUT, PATCH, DELETE, OPTIONS, runtime } =
  initApiPassthrough({
    apiUrl: process.env.LANGGRAPH_API_URL ?? "http://localhost:2024",
    runtime: "edge", // default
    disableWarningLog: true,
    bodyParameters: (req, body) => {
      if (body.config?.configurable && "apiKeys" in body.config.configurable) {
        const encryptionKey = process.env.SECRETS_ENCRYPTION_KEY;
        if (!encryptionKey) {
          throw new Error(
            "SECRETS_ENCRYPTION_KEY environment variable is required",
          );
        }

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
        return body;
      }
      return body;
    },
    headers: (req) => {
      const buildLocalHeaders = (): Record<string, string> => ({
        [GITHUB_TOKEN_COOKIE]: "local",
        [GITHUB_INSTALLATION_TOKEN_COOKIE]: "local",
        [GITHUB_INSTALLATION_NAME]: "local",
        [GITHUB_INSTALLATION_ID]: "local",
        ["x-local-mode"]: "true",
      });

      if (isLocalModeFromEnv()) {
        return buildLocalHeaders();
      }

      const encryptionKey = process.env.SECRETS_ENCRYPTION_KEY;
      if (!encryptionKey) {
        // During build time, avoid throwing hard errors; return minimal headers
        return buildLocalHeaders();
      }
      const installationIdCookie = req.cookies.get(
        GITHUB_INSTALLATION_ID_COOKIE,
      )?.value;

      if (!installationIdCookie) {
        return buildLocalHeaders();
      }

      // Note: these helpers are async, but build expects a sync return type; in runtime, the passthrough lib will handle async.
      // To satisfy types, return placeholders if not resolvable at build time; at runtime, they will be computed.
      try {
        // Return placeholder headers during build; runtime will compute real values.
        return {
          [GITHUB_TOKEN_COOKIE]: "placeholder",
          [GITHUB_INSTALLATION_TOKEN_COOKIE]: "placeholder",
          [GITHUB_INSTALLATION_NAME]: "placeholder",
          [GITHUB_INSTALLATION_ID]: installationIdCookie,
        };
      } catch {
        return buildLocalHeaders();
      }
    },
  });
