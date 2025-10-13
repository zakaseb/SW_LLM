# LM Studio Local Integration Setup

This guide explains how to configure Open SWE to use LM Studio for completely local LLM inference.

## Prerequisites

1. **LM Studio installed and running**
   - Download from: https://lmstudio.ai/
   - Load a model capable of tool calling and structured output (recommended: models with 7B+ parameters)
   - Start the local server (default: http://127.0.0.1:1234)

2. **Model Requirements**
   - The model should support:
     - Tool/function calling (OpenAI-compatible format)
     - JSON structured output
     - Context window of at least 8K tokens (16K+ recommended)
   
3. **Recommended Models**
   - `openai/gpt-oss-20b` - Good balance of performance and speed
   - `mistralai/Mistral-7B-Instruct-v0.3` - Fast, supports function calling
   - Any model with "tool" or "function" calling capabilities

## Configuration Steps

### 1. Environment Variables

Add the following to your `.env` files:

#### For `apps/open-swe/.env`:

```bash
# LM Studio Configuration
USE_LM_STUDIO=true
LM_STUDIO_BASE_URL=http://127.0.0.1:1234/v1
LM_STUDIO_MODEL_NAME=lmstudio-local

# Note: When using LM Studio, you don't need API keys for Anthropic/OpenAI/Google
# But you still need these for the system to work:
SECRETS_ENCRYPTION_KEY=your-encryption-key-here
LANGCHAIN_API_KEY=your-langsmith-key-here
```

#### For `apps/web/.env`:

```bash
# Same as before - no changes needed for web app
NEXT_PUBLIC_API_URL=http://localhost:3000/api
LANGGRAPH_API_URL=http://localhost:2024
SECRETS_ENCRYPTION_KEY=your-encryption-key-here
# ... rest of your config
```

### 2. LM Studio Server Setup

1. **Open LM Studio**
2. **Load a model** from the model library
3. **Start the local server:**
   - Go to "Local Server" tab
   - Click "Start Server"
   - Default port is 1234
   - Verify it's running at http://127.0.0.1:1234

4. **Test the connection:**
   ```bash
   curl http://127.0.0.1:1234/v1/models
   ```
   Should return a list of loaded models.

### 3. Model Selection in UI

Even with `USE_LM_STUDIO=true`, you can override models in the UI:

1. Go to Settings → Configuration
2. Select "LM Studio Local" from any model dropdown:
   - Planner Model
   - Programmer Model
   - Reviewer Model
   - Router Model
   - Summarizer Model

3. No API key required for LM Studio models

## Environment Variable Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `USE_LM_STUDIO` | `false` | Set to `true` to use LM Studio for all tasks by default |
| `LM_STUDIO_BASE_URL` | `http://127.0.0.1:1234/v1` | LM Studio server endpoint |
| `LM_STUDIO_MODEL_NAME` | `lmstudio-local` | Model identifier (can be anything, LM Studio uses loaded model) |

## How It Works

### Architecture

1. **Provider Abstraction**: LM Studio is registered as a new provider type `lmstudio`
2. **OpenAI Compatibility**: Internally uses OpenAI SDK with custom base URL
3. **Tool Calling**: LM Studio supports OpenAI-compatible tool calling format
4. **Structured Output**: Supports `response_format` with JSON schema

### Request Flow

```
OpenSWE Agent
    ↓
Model Manager (detects lmstudio provider)
    ↓
LangChain initChatModel with:
  - modelProvider: "openai" (for compatibility)
  - baseURL: http://127.0.0.1:1234/v1
  - apiKey: "lm-studio" (dummy, not validated)
    ↓
LM Studio Local Server
    ↓
Your Local Model
```

### Payload Format

LM Studio receives standard OpenAI format:

```json
{
  "model": "lmstudio-local",
  "messages": [
    {"role": "system", "content": "..."},
    {"role": "user", "content": "..."}
  ],
  "tools": [...],
  "temperature": 0,
  "max_tokens": 10000
}
```

## Testing

### Quick Test Script

Create a test file to verify the integration:

```bash
cd apps/open-swe
node -e "
const { createLangGraphClient } = require('./dist/utils/langgraph-client.js');
console.log('Testing LM Studio connection...');
"
```

Or use the provided test script:

```bash
yarn test:lmstudio
```

### Verify Tool Calling

The model should be able to:
1. Parse tool definitions from the `tools` array
2. Return `tool_calls` in the response when appropriate
3. Handle multiple sequential tool calls
4. Support structured JSON output via `response_format`

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure LM Studio server is running
   - Check the port (default 1234)
   - Verify firewall settings

2. **Model Not Responding**
   - Ensure a model is loaded in LM Studio
   - Check model supports tool calling
   - Increase context window in LM Studio settings

3. **Tool Calling Failures**
   - Use a model with explicit tool calling support
   - Models below 7B parameters may struggle
   - Try increasing temperature slightly (0.1-0.3)

4. **API Key Errors**
   - Set `USE_LM_STUDIO=true` to skip API key validation
   - Or select "LM Studio Local" in UI settings

### Performance Tips

1. **Model Selection**: Larger models (13B+) perform better but are slower
2. **Quantization**: Q4 or Q5 quantized models offer good balance
3. **Context Window**: Ensure model supports 16K+ tokens for complex tasks
4. **GPU Acceleration**: Enable GPU in LM Studio for faster inference

## GitHub Integration

LM Studio works seamlessly with GitHub integration:

- GitHub authentication remains unchanged
- Repository access works normally
- Only LLM inference is local
- All GitHub API calls still go through external APIs

## Switching Between Local and Cloud

To switch between LM Studio and cloud providers:

1. **Use LM Studio**: Set `USE_LM_STUDIO=true`
2. **Use Cloud APIs**: Set `USE_LM_STUDIO=false` and provide API keys
3. **Mix Both**: Use LM Studio as default, override specific tasks in UI

## Advanced Configuration

### Custom Model Names

If your LM Studio model has a specific identifier:

```bash
LM_STUDIO_MODEL_NAME=mistral-7b-instruct
```

### Custom Ports

If LM Studio runs on a different port:

```bash
LM_STUDIO_BASE_URL=http://127.0.0.1:8080/v1
```

### Multiple Models

LM Studio loads one model at a time, but you can:
1. Use different model names for different tasks (all route to loaded model)
2. Manually switch models in LM Studio between runs
3. Use cloud providers as fallback for specific tasks

## Security Considerations

- **Data Privacy**: All LLM requests stay local
- **No API Keys**: LM Studio doesn't require or validate API keys
- **Network**: No external LLM API calls when using LM Studio
- **GitHub**: GitHub integration still requires internet access

## Support

For issues:
1. Check LM Studio documentation: https://lmstudio.ai/docs
2. Verify model capabilities (tool calling, JSON output)
3. Review LM Studio server logs
4. Check OpenSWE logs for connection errors

