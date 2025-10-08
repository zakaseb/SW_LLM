import { Hono } from "hono";
import { cors } from "hono/cors";
import { issueWebhookHandler } from "./github/issue-webhook.js";

export const app = new Hono();

app.use("*", cors({ origin: "http://localhost:3000", credentials: true }));
app.post("/webhooks/github", issueWebhookHandler);
