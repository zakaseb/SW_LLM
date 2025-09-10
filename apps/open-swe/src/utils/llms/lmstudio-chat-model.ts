import { ChatOpenAI, ChatOpenAIFields } from "@langchain/openai";
import { BindToolsInput } from "@langchain/core/language_models/chat_models";

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
}
