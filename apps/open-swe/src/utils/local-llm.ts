import { ChatOpenAI } from "@langchain/openai";

export const LocalLLM = new ChatOpenAI({
  model: "openai/gpt-oss-20b",
  openAIApiKey: process.env.OPENAI_API_KEY || "lmstudio-local",
  configuration: {
    baseURL: process.env.OPENAI_API_BASE || "http://localhost:1234/v1",
  },
});