import { ChatOpenAI, ChatOpenAIFields } from "@langchain/openai";
import {
  BindToolsInput,
  ChatResult,
} from "@langchain/core/language_models/chat_models";
import { BaseMessage } from "@langchain/core/messages";
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
    options: this["CallOptions"],
    runManager?: CallbackManagerForLLMRun,
  ): Promise<ChatResult> {
    if (options.tool_choice && typeof options.tool_choice === "object") {
      options.tool_choice = "required";
    }
    return super._generate(messages, options, runManager);
  }
}
