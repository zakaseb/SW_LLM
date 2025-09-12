import { ChatOpenAI, ChatOpenAIFields } from "@langchain/openai";
import {
  BindToolsInput,
  ChatResult,
} from "@langchain/core/language_models/chat_models";
import { BaseMessage } from "@langchain/core/messages";
import { CallbackManagerForLLMRun } from "@langchain/core/callbacks/manager";

// Helper to sanitize payload for LM Studio
function sanitizeLmStudioPayload(payload: any) {
  // 1) Sanitize tool_choice
  if (payload.tool_choice && typeof payload.tool_choice === "object") {
    // Try to extract a reasonable string from common shapes
    const tc = payload.tool_choice;
    // If someone passed { type: 'auto' } or { name: 'auto' }
    if (typeof tc.type === "string" && ["none","auto","required"].includes(tc.type)) {
      payload.tool_choice = tc.type;
    } else if (typeof tc.name === "string" && ["none","auto","required"].includes(tc.name)) {
      payload.tool_choice = tc.name;
    } else if (typeof tc === "object" && tc.required === true) {
      payload.tool_choice = "required";
    } else {
      // default fallback — choose 'auto' since it's the safest general behavior
      payload.tool_choice = "auto";
    }
  }

  // 2) Convert response_format -> LM Studio style if needed
  // LM Studio wants: { type: "json_schema", json_schema: { name, strict, schema: { ... } } } or { type: "text" }
  if (payload.response_format && typeof payload.response_format === "object") {
    const rf = payload.response_format;

    // If it's already valid, keep it
    if (rf.type === "json_schema" || rf.type === "text") {
      // keep as-is
    } else {
      // Common case: LangChain might have produced a schema object directly
      // e.g. { type: "object", properties: { ... }, required: [...] } or similar
      // Wrap that as json_schema
      const wrappedSchema = {
        type: "json_schema",
        json_schema: {
          name: rf.name ?? "structured_output",
          strict: rf.strict === true || rf.strict === "true" ? true : true, // default to strict
          // If the user already provided a top-level 'schema', use it; otherwise assume rf itself is the schema
          schema: rf.schema ?? (rf.type ? rf : rf),
        },
      };
      payload.response_format = wrappedSchema;
    }
  }

  // 3) Defensive: remove unsupported top-level fields that LMStudio may reject
  // (adjust this list if LMStudio accepts additional fields)
  // e.g. openai-style 'functions' may not be supported — move them to 'tools' or drop
  if (payload.functions && Array.isArray(payload.functions) && payload.functions.length > 0) {
    // If you want to keep, map to 'tools' shape expected by your app, otherwise delete.
    // For now, delete to avoid LM Studio rejecting the payload.
    delete payload.functions;
  }

  return payload;
}

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
    const payload = {
      messages,
      ...options,
    };
    const finalPayload = sanitizeLmStudioPayload(payload);
    return super._generate(
      finalPayload.messages,
      finalPayload,
      runManager,
    );
  }
}
