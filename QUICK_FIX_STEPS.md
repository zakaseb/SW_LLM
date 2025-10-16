# Quick Fix: Configure Router & Summarizer Models

## Problem
Error: "All fallback models exhausted for task router"

## Solution (2 minutes)

### Step 1: Open Settings
Go to: **http://localhost:3000/settings?tab=configuration**

### Step 2: Scroll Down & Configure These Fields

Find and set:

| Field | Value |
|-------|-------|
| **routerModelName** | `lmstudio:local-model` |
| **routerTemperature** | `0` |
| **summarizerModelName** | `lmstudio:local-model` |
| **summarizerTemperature** | `0` |

**Note**: Replace `local-model` with your actual LM Studio model ID if different.

### Step 3: Test
1. Go to main page: http://localhost:3000
2. Select a repository and branch
3. Submit a test task: "Add a comment to README.md saying 'Hello World'"
4. Check LM Studio logs to see requests

## What Changed?
- Added ROUTER and SUMMARIZER model configurations to the UI
- These were missing, causing OpenSWE to try Anthropic/Google models
- Now all 5 LLM tasks (PLANNER, PROGRAMMER, REVIEWER, ROUTER, SUMMARIZER) can use LM Studio

## Verification Checklist
- [ ] LM Studio is running
- [ ] Model is loaded in LM Studio
- [ ] All 5 model configs in Settings show `lmstudio:local-model`
- [ ] Test task submitted successfully
- [ ] LM Studio logs show incoming requests

## If Still Having Issues

1. **Check LM Studio Model Name**
   - Go to LM Studio → Model tab
   - Note the model ID (e.g., `llama-3.2-3b-instruct`)
   - Use format: `lmstudio:llama-3.2-3b-instruct`

2. **Check LM Studio Port**
   - Default: http://127.0.0.1:1234/v1
   - Set in `apps/open-swe/.env`: `LM_STUDIO_BASE_URL=http://127.0.0.1:1234/v1`

3. **Check Backend Logs**
   - Look in Terminal 1 for LM Studio connection errors
   - Common issues: model not loaded, wrong port, wrong model name

## Detailed Documentation
See: `LM_STUDIO_ROUTER_FIX.md` for full technical explanation.

