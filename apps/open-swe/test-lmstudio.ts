/* eslint-disable no-console */
import { ChatOpenAI } from "@langchain/openai";

const LM_STUDIO_BASE_URL = process.env.LM_STUDIO_BASE_URL || "http://127.0.0.1:1234/v1";
const LM_STUDIO_MODEL_NAME = process.env.LM_STUDIO_MODEL_NAME || "lmstudio-local";

async function testLMStudioConnection() {
  console.log("🧪 Testing LM Studio Connection...\n");
  console.log(`Base URL: ${LM_STUDIO_BASE_URL}`);
  console.log(`Model Name: ${LM_STUDIO_MODEL_NAME}\n`);

  try {
    const model = new ChatOpenAI({
      modelName: LM_STUDIO_MODEL_NAME,
      openAIApiKey: "lm-studio",
      configuration: {
        baseURL: LM_STUDIO_BASE_URL,
      },
      temperature: 0,
      maxTokens: 500,
    });

    console.log("✅ Model initialized successfully\n");

    console.log("📝 Test 1: Basic completion...");
    const response1 = await model.invoke([
      {
        role: "system",
        content: "You are a helpful coding assistant.",
      },
      {
        role: "user",
        content: "Write a simple hello world function in TypeScript.",
      },
    ]);

    console.log("Response:");
    console.log(response1.content);
    console.log("\n✅ Test 1 passed!\n");

    console.log("📝 Test 2: Tool calling...");
    
    const tools = [
      {
        type: "function" as const,
        function: {
          name: "search_code",
          description: "Search for code in the codebase",
          parameters: {
            type: "object",
            properties: {
              query: {
                type: "string",
                description: "The search query",
              },
            },
            required: ["query"],
          },
        },
      },
    ];

    const modelWithTools = model.bind({
      tools: tools,
    });

    const response2 = await modelWithTools.invoke([
      {
        role: "system",
        content: "You are a helpful assistant with access to code search tools.",
      },
      {
        role: "user",
        content: "Search for authentication functions in the codebase.",
      },
    ]);

    if (response2.tool_calls && response2.tool_calls.length > 0) {
      console.log("Tool calls:");
      console.log(JSON.stringify(response2.tool_calls, null, 2));
      console.log("\n✅ Test 2 passed! Tool calling works!\n");
    } else {
      console.log("⚠️  Test 2: Model did not use tools (this is okay, depends on model capability)");
      console.log("Response:", response2.content);
      console.log("\n");
    }

    console.log("📝 Test 3: Structured output (JSON)...");
    
    const modelWithStructured = new ChatOpenAI({
      modelName: LM_STUDIO_MODEL_NAME,
      openAIApiKey: "lm-studio",
      configuration: {
        baseURL: LM_STUDIO_BASE_URL,
      },
      temperature: 0,
      maxTokens: 500,
      modelKwargs: {
        response_format: {
          type: "json_object",
        },
      },
    });

    const response3 = await modelWithStructured.invoke([
      {
        role: "system",
        content: "You are a helpful assistant. Always respond with valid JSON.",
      },
      {
        role: "user",
        content: "Create a JSON object with fields: name (string), age (number), skills (array of strings) for a senior TypeScript developer.",
      },
    ]);

    console.log("JSON Response:");
    console.log(response3.content);
    
    try {
      JSON.parse(response3.content as string);
      console.log("\n✅ Test 3 passed! Valid JSON output!\n");
    } catch {
      console.log("\n⚠️  Test 3: Response is not valid JSON (this is okay, depends on model capability)\n");
    }

    console.log("🎉 All tests completed!");
    console.log("\n📊 Summary:");
    console.log("- Basic completion: ✅");
    console.log("- Tool calling: Check above");
    console.log("- Structured output: Check above");
    console.log("\nYour LM Studio integration is working! 🚀");

  } catch (error) {
    console.error("\n❌ Error testing LM Studio connection:");
    console.error(error);
    console.error("\n🔍 Troubleshooting:");
    console.error("1. Ensure LM Studio is running");
    console.error("2. Check that a model is loaded");
    console.error("3. Verify the server is at:", LM_STUDIO_BASE_URL);
    console.error("4. Check LM Studio logs for errors");
    process.exit(1);
  }
}

testLMStudioConnection().catch(console.error);

