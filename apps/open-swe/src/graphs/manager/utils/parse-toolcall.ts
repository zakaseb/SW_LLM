import { AIMessageChunk } from "@langchain/core/messages";
import { z } from "zod";
import { BASE_CLASSIFICATION_SCHEMA } from "../nodes/classify-message/schemas.js";

function stripCodeFences(text: string): string {
  // If the model wraps JSON in ```json ... ``` return inner, else return text
  const m = text.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
  return m ? m[1].trim() : text;
}

function extractFirstBalancedObject(text: string): string | null {
  // Find the first substring that is a balanced {...}
  const starts: number[] = [];
  for (let i = 0; i < text.length; i++) {
    if (text[i] === "{") starts.push(i);
  }
  for (const start of starts) {
    let depth = 0;
    for (let j = start; j < text.length; j++) {
      if (text[j] === "{") depth++;
      else if (text[j] === "}") {
        depth--;
        if (depth === 0) {
          return text.slice(start, j + 1);
        }
      }
    }
  }
  return null;
}

function repairJsonLikeString(s: string): string {
  let t = s.trim();

  // Convert 'single quoted' strings to "double quoted" (naive but useful)
  t = t.replace(/'([^']*?)'/g, (_, inner) => `"${inner.replace(/"/g, '\\"')}"`);

  // Remove trailing commas before } or ]
  t = t.replace(/,(\s*[}\]])/g, "$1");

  return t;
}

export function parseToolCallFromResult(response: AIMessageChunk): {
  tool_calls: {
    name: string;
    args: any;
    id: string;
    type: string;
  }[];
} {
  let toolCall: { name: string; args: any } | undefined =
    response.tool_calls?.[0];

  if (!toolCall) {
    const raw = (response.content ?? JSON.stringify(response)).toString();
    console.log("[classify-message] raw LLM output:", raw);

    const candidate = stripCodeFences(raw);
    let parsed;
    try {
      parsed = JSON.parse(candidate);
    } catch {
      const jsonSub = extractFirstBalancedObject(candidate);
      if (jsonSub) {
        try {
          parsed = JSON.parse(jsonSub);
        } catch {
          try {
            const repaired = repairJsonLikeString(jsonSub);
            parsed = JSON.parse(repaired);
          } catch {
            // ignore
          }
        }
      } else {
        try {
          const repaired = repairJsonLikeString(candidate);
          parsed = JSON.parse(repaired);
        } catch {
          // ignore
        }
      }
    }

    if (parsed && (parsed.name || parsed.tool || parsed.action)) {
      toolCall = {
        name: parsed.name ?? parsed.tool ?? parsed.action,
        args: parsed.arguments ?? parsed.args ?? parsed,
      };
    }
  }

  const safeTool = BASE_CLASSIFICATION_SCHEMA.safeParse(toolCall?.args);
  let toolArgs;
  if (!safeTool.success) {
    toolArgs = {
      route: "no_op",
      response: "Invalid arguments, fell back.",
    };
  } else {
    toolArgs = safeTool.data;
  }

  if (!toolCall) {
    console.error(
      "[classify-message] Failed to parse tool call from LLM response — using fallback tool.",
    );
    toolCall = {
      name: "request_human_help",
      args: {
        original_text: (response.content ?? "").toString(),
      },
    };
  } else {
    toolCall.args = toolArgs;
  }

  return {
    tool_calls: [
      {
        id: "ollama_tool_1",
        type: "function",
        ...toolCall,
      },
    ],
  };
}
