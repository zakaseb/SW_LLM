import { ChatOpenAI, ChatOpenAIFields } from "@langchain/openai";
import { BindToolsInput } from "@langchain/core/language_models/chat_models";
import { BaseMessage } from "@langchain/core/messages";
import { ChatResult } from "@langchain/core/outputs";
import { CallbackManagerForLLMRun } from "@langchain/core/callbacks/manager";

export class LMStudioChatModel extends ChatOpenAI {
  constructor(fields?: ChatOpenAIFields) {
    super(fields);
  }

  bindTools(
    tools: BindToolsInput,
    kwargs?: Record<string, any>,
  ): this {
    const newKwargs = { ...kwargs };
    if (newKwargs.tool_choice && typeof newKwargs.tool_choice === "object") {
      newKwargs.tool_choice = "required";
    }
    const toolsArray = Array.isArray(tools) ? tools : [tools];
    return super.bindTools(toolsArray as any[], newKwargs) as this;
  }

  async _generate(
    messages: BaseMessage[],
    options: this["ParsedCallOptions"],
    runManager?: CallbackManagerForLLMRun,
  ): Promise<ChatResult> {
    const newOptions = { ...options };
    if (
      newOptions.response_format &&
      newOptions.response_format.type === "json_object"
    ) {
      newOptions.response_format = {
        type: "json_schema",
        json_schema: {
          name: "structured_output",
          strict: true,
          schema: newOptions.response_format,
        },
      } as any;
    }
    return super._generate(messages, newOptions, runManager);
  }
}
