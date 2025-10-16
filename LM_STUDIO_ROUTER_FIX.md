# LM Studio Router & Summarizer Model Configuration Fix

## The Problem

When submitting a task to OpenSWE with LM Studio configured, you encountered this error:

```
All fallback models exhausted for task router. Last error: Please set an API key for Google GenerativeAI
```

## Root Cause

OpenSWE uses **5 different LLM tasks**, each requiring a model configuration:
1. **PLANNER** - Plans tasks and gathers context
2. **PROGRAMMER** - Writes code and implements changes
3. **REVIEWER** - Reviews code and suggests improvements
4. **ROUTER** - Routes messages, classifies requests, generates PR titles/descriptions
5. **SUMMARIZER** - Summarizes conversations and actions

When you configured "LM Studio Local" in the UI settings, you only configured the first three (PLANNER, PROGRAMMER, REVIEWER). The **ROUTER** and **SUMMARIZER** models were still set to their defaults:
- ROUTER: `anthropic:claude-3-5-haiku-latest`
- SUMMARIZER: `anthropic:claude-sonnet-4-0`

When you submitted a task, it tried to use the ROUTER model first (for message classification), but since you had no Anthropic API key, it failed and tried fallback models, eventually exhausting all options including Google GenAI.

## What Was Fixed

### 1. **Code Changes**
   - ✅ Removed duplicate `routerModelName`, `routerTemperature`, `summarizerModelName`, `summarizerTemperature` configurations in `packages/shared/src/open-swe/types.ts`
   - ✅ Fixed the import statement to only import `MODEL_OPTIONS_NO_THINKING`
   - ✅ Changed router config to use `MODEL_OPTIONS_NO_THINKING` (router tasks don't need thinking models)
   - ✅ Rebuilt the shared package: `yarn workspace @open-swe/shared build`
   - ✅ Restarted both frontend and backend servers

### 2. **Servers Running**
   - Frontend: http://localhost:3000
   - Backend: http://127.0.0.1:2024

## How to Fix It (Action Required)

Now you need to configure the ROUTER and SUMMARIZER models in the UI:

1. **Open the Settings Page**
   - Go to: http://localhost:3000/settings?tab=configuration

2. **Scroll Down** to find the new model configuration options:
   - **Router Model Name** - Set to `lmstudio:local-model`
   - **Router Temperature** - Leave at `0` (default)
   - **Summarizer Model Name** - Set to `lmstudio:local-model`
   - **Summarizer Temperature** - Leave at `0` (default)

3. **Save the Configuration**
   - The changes save automatically

4. **Test the Setup**
   - Go back to the main chat page
   - Select your repository and branch
   - Submit a test task
   - It should now use LM Studio for all LLM operations

## How the Router Task Works

The ROUTER task is used in several places:
- **Message Classification** (`classify-message/index.ts`) - Determines how to route incoming messages (to planner, programmer, etc.)
- **Context Determination** (`determine-needs-context.ts`) - Decides if more context is needed before planning
- **PR Generation** (`open-pr.ts`) - Generates PR titles and descriptions

It's a lightweight task that doesn't need advanced reasoning, which is why it defaults to Claude Haiku (a smaller, faster model).

## How the Summarizer Task Works

The SUMMARIZER task is used for:
- Summarizing conversation history
- Extracting key context from large inputs
- Condensing action logs

It requires good context understanding but doesn't need to write code, so it also defaults to a lighter model.

## Verification

To verify everything is working:

1. **Check LM Studio** is running with a model loaded
2. **Check the configuration** in Settings → Configuration shows:
   - Planner Model: `lmstudio:local-model`
   - Programmer Model: `lmstudio:local-model`
   - Reviewer Model: `lmstudio:local-model`
   - Router Model: `lmstudio:local-model` ← **NEW**
   - Summarizer Model: `lmstudio:local-model` ← **NEW**
3. **Submit a task** and watch the LM Studio server logs to see requests coming in

## Why This Happened

The UI configuration page displays all fields from `GraphConfigurationMetadata` in `packages/shared/src/open-swe/types.ts`. The ROUTER and SUMMARIZER configurations existed in the code but had duplicate entries, which caused TypeScript compilation errors. After fixing the duplicates and rebuilding, these options are now properly exposed in the UI.

## Summary

- **Issue**: Router and Summarizer models weren't configured for LM Studio
- **Fix**: Exposed these configurations in the UI
- **Action**: Configure them in Settings → Configuration
- **Result**: All 5 LLM tasks now use LM Studio

## Next Steps

Once you've configured the ROUTER and SUMMARIZER models:
1. Test with a simple task like "Add a comment to README.md"
2. Check LM Studio logs to confirm all requests are going to the local model
3. Verify the task completes successfully

If you still encounter issues, check:
- LM Studio is running and has a model loaded
- The model name in settings matches the LM Studio model ID
- The LM Studio server is accessible at http://127.0.0.1:1234/v1

