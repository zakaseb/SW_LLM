import { v4 as uuidv4 } from "uuid";
import { isAIMessage, ToolMessage } from "@langchain/core/messages";
import { zodToJsonSchema } from "zod-to-json-schema";
import { GraphConfig } from "@open-swe/shared/open-swe/types";
import {
  loadModel,
  supportsParallelToolCallsParam,
} from "../../../../utils/llms/index.js";
import { LLMTask } from "@open-swe/shared/open-swe/llm-task";
import {
  PlannerGraphState,
  PlannerGraphUpdate,
} from "@open-swe/shared/open-swe/planner/types";
import { formatUserRequestPrompt } from "../../../../utils/user-request.js";
import {
  formatFollowupMessagePrompt,
  isFollowupRequest,
} from "../../utils/followup.js";
import { stopSandbox } from "../../../../utils/sandbox.js";
import { z } from "zod";
import { formatCustomRulesPrompt } from "../../../../utils/custom-rules.js";
import { getScratchpad } from "../../utils/scratchpad-notes.js";
import { SCRATCHPAD_PROMPT, SYSTEM_PROMPT } from "./prompt.js";
import { DO_NOT_RENDER_ID_PREFIX } from "@open-swe/shared/constants";
import { filterMessagesWithoutContent } from "../../../../utils/message/content.js";
import { getModelManager } from "../../../../utils/llms/model-manager.js";
import { trackCachePerformance } from "../../../../utils/caching.js";
import { isLocalMode } from "@open-swe/shared/open-swe/local-mode";

function formatSystemPrompt(state: PlannerGraphState): string {
  // It's a followup if there's more than one human message.
  const isFollowup = isFollowupRequest(state.taskPlan, state.proposedPlan);
  const scratchpad = getScratchpad(state.messages)
    .map((n) => `- ${n}`)
    .join("\n");
  return SYSTEM_PROMPT.replace(
    "{FOLLOWUP_MESSAGE_PROMPT}",
    isFollowup
      ? "\n" +
          formatFollowupMessagePrompt(state.taskPlan, state.proposedPlan) +
          "\n\n"
      : "",
  )
    .replace("{USER_REQUEST_PROMPT}", formatUserRequestPrompt(state.messages))
    .replaceAll("{CUSTOM_RULES}", formatCustomRulesPrompt(state.customRules))
    .replaceAll(
      "{SCRATCHPAD}",
      scratchpad.length
        ? SCRATCHPAD_PROMPT.replace("{SCRATCHPAD}", scratchpad)
        : "",
    );
}

export async function generatePlan(
  state: PlannerGraphState,
  config: GraphConfig,
): Promise<PlannerGraphUpdate> {
  const model = await loadModel(config, LLMTask.PLANNER);
  const modelManager = getModelManager();
  const modelName = modelManager.getModelNameForTask(config, LLMTask.PLANNER);
  const modelSupportsParallelToolCallsParam = supportsParallelToolCallsParam(
    config,
    LLMTask.PLANNER,
  );
  const schema = z.object({
    title: z.string().describe("The title of the session plan."),
    plan: z.array(z.string()).describe("The steps of the session plan."),
  });
  const jsonSchema = zodToJsonSchema(schema);
  const modelWithJson = model.bind({
    response_format: {
      type: "json_schema",
      json_schema: {
        name: "session_plan",
        strict: true,
        schema: jsonSchema,
      },
    },
  });

  const response = await modelWithJson
    .withConfig({ tags: ["nostream"] })
    .invoke(formatSystemPrompt(state));

  const proposedPlanArgs = JSON.parse(response.content as string);

  let newSessionId: string | undefined;
  if (state.sandboxSessionId && !isLocalMode(config)) {
    // Stop before returning, as the next step will be to interrupt the graph.
    newSessionId = await stopSandbox(state.sandboxSessionId);
  }

  return {
    messages: [],
    proposedPlanTitle: proposedPlanArgs.title,
    proposedPlan: proposedPlanArgs.plan,
    ...(newSessionId && { sandboxSessionId: newSessionId }),
    tokenData: trackCachePerformance(response, modelName),
  };
}
