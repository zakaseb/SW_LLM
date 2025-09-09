import { ChatOpenAI } from "@langchain/openai";
import {
  LLMTask,
  TASK_TO_CONFIG_DEFAULTS_MAP,
} from "@open-swe/shared/open-swe/llm-task";
import { GraphConfig } from "@open-swe/shared/open-swe/types";

export function getLMStudioClient(
  config: GraphConfig,
  task: LLMTask,
): ChatOpenAI | null {
  const baseURL = process.env.LMSTUDIO_BASE_URL;
  if (!baseURL) {
    return null;
  }

  const modelStr =
    config.configurable?.[`${task}ModelName`] ??
    TASK_TO_CONFIG_DEFAULTS_MAP[task].modelName;

  const [_provider, ...modelNameParts] = modelStr.split(":");
  const modelName = modelNameParts.join(":");

  return new ChatOpenAI({
    apiKey: process.env.LMSTUDIO_API_KEY ?? "not-needed",
    modelName: modelName,
    configuration: {
      baseURL: process.env.LMSTUDIO_BASE_URL,
    },
  });
}
