import { App } from "@octokit/app";
import { Octokit } from "@octokit/core";

const replaceNewlinesWithBackslashN = (str: string) =>
  str.replace(/\n/g, "\\n");

export class GitHubApp {
  app: App;

  constructor() {
    const appId = process.env.GITHUB_APP_ID;
    const privateKey = process.env.GITHUB_APP_PRIVATE_KEY
      ? replaceNewlinesWithBackslashN(process.env.GITHUB_APP_PRIVATE_KEY)
      : undefined;
    const webhookSecret = process.env.GITHUB_WEBHOOK_SECRET;
    const isLocalMode = process.env.OPEN_SWE_LOCAL_MODE === "true";

    // In local mode, GitHub webhooks are not used, so allow missing configuration
    if (!appId || !privateKey || !webhookSecret) {
      if (!isLocalMode) {
        throw new Error(
          "GitHub App ID, Private Key, or Webhook Secret is not configured.",
        );
      }
      // Use dummy values in local mode (webhooks won't work but backend will start)
      this.app = new App({
        appId: "123456",
        privateKey: "-----BEGIN RSA PRIVATE KEY-----\\nMIIEowIBAAKCAQEA2Z2Zn5p0x8+6P4K8L8h5k6j3m2l1n0o9p8q7r6s5t4u3v2w1\\nx0y9z8A7B6C5D4E3F2G1H0I9J8K7L6M5N4O3P2Q1R0S9T8U7V6W5X4Y3Z2a1b0c9\\nd8e7f6g5h4i3j2k1l0m9n8o7p6q5r4s3t2u1v0w9x8y7z6A5B4C3D2E1F0G9H8I7\\nJ6K5L4M3N2O1P0Q9R8S7T6U5V4W3X2Y1Z0a9b8c7d6e5f4g3h2i1j0k9l8m7n6o5\\np4q3r2s1t0u9v8w7x6y5z4A3B2C1D0E9F8G7H6I5J4K3L2M1N0O9P8Q7R6S5T4U3\\nV2W1X0Y9Z8a7b6c5d4e3f2g1h0i9j8k7l6m5n4o3p2q1r0s9t8u7v6w5x4y3z2A1\\nB0C9D8E7F6G5H4I3J2K1L0M9N8O7P6Q5R4S3T2U1V0W9X8Y7Z6a5b4c3d2e1f0g9\\nh8i7j6k5l4m3n2o1p0q9r8s7t6u5v4w3x2y1z0A9B8C7D6E5F4G3H2I1J0K9L8M7\\nN6O5P4Q3R2S1T0U9VwIDAQABAoIBAGzYa1b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7\\n-----END RSA PRIVATE KEY-----",
        webhooks: {
          secret: "dummy_webhook_secret_for_local_mode",
        },
      });
      return;
    }

    this.app = new App({
      appId,
      privateKey,
      webhooks: {
        secret: webhookSecret,
      },
    });
  }

  async getInstallationOctokit(installationId: number): Promise<Octokit> {
    return await this.app.getInstallationOctokit(installationId);
  }

  async getInstallationAccessToken(installationId: number): Promise<{
    token: string;
    expiresAt: string;
  }> {
    const octokit = await this.app.getInstallationOctokit(installationId);

    // The installation access token is available on the auth property
    const auth = (await octokit.auth({
      type: "installation",
    })) as any;

    return {
      token: auth.token,
      expiresAt: auth.expiresAt,
    };
  }
}
