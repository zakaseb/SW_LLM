import { AIMessageChunk } from "@langchain/core/messages";

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
  let toolCall = response.tool_calls?.[0];

  if (!toolCall) {
    // Get raw text from common fields (adjust if your wrapper uses different names)
    const raw = (
      response.content ??
      JSON.stringify(response)
    ).toString();

    // Log raw output for debugging (persist if you prefer)
    console.log("[classify-message] raw LLM output:", raw);

    // 1) strip fences
    const candidate = stripCodeFences(raw);

    // 2) try parsing candidate directly
    try {
      const parsed = JSON.parse(candidate);
      if (parsed && (parsed.name || parsed.tool || parsed.action)) {
        toolCall = {
          name: parsed.name ?? parsed.tool ?? parsed.action,
          args: parsed.arguments ?? parsed.args ?? parsed,
        };
      }
    } catch (_) {
      // 3) try to extract a balanced JSON substring
      const jsonSub = extractFirstBalancedObject(candidate);
      if (jsonSub) {
        try {
          const parsed2 = JSON.parse(jsonSub);
          if (parsed2 && (parsed2.name || parsed2.tool || parsed2.action)) {
            toolCall = {
              name: parsed2.name ?? parsed2.tool ?? parsed2.action,
              args: parsed2.arguments ?? parsed2.args ?? parsed2,
            };
          }
        } catch (_) {
          // 4) attempt lightweight repair then parse
          try {
            const repaired = repairJsonLikeString(jsonSub || candidate);
            const parsed3 = JSON.parse(repaired);
            if (parsed3 && (parsed3.name || parsed3.tool || parsed3.action)) {
              toolCall = {
                name: parsed3.name ?? parsed3.tool ?? parsed3.action,
                args: parsed3.arguments ?? parsed3.args ?? parsed3,
              };
            }
          } catch (__) {
            // nothing left
          }
        }
      } else {
        // Try repairing entire candidate if no balanced substring was found
        try {
          const repairedWhole = repairJsonLikeString(candidate);
          const parsed4 = JSON.parse(repairedWhole);
          if (parsed4 && (parsed4.name || parsed4.tool || parsed4.action)) {
            toolCall = {
              name: parsed4.name ?? parsed4.tool ?? parsed4.action,
              args: parsed4.arguments ?? parsed4.args ?? parsed4,
            };
          }
        } catch (__) {
          // still nothing
        }
      }
    }
  }

  // If still no toolCall, return a safe fallback (do NOT throw)
  if (!toolCall) {
    console.error(
      "[classify-message] Failed to parse tool call from LLM response — using fallback tool.",
    );
    toolCall = {
      name: "request_human_help", // map this to a real tool in your tool registry (or use "default_handler")
      args: {
        original_text: (
          response.content ?? ""
        ).toString(),
      },
    };
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
