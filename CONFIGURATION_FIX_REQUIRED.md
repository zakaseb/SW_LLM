# 🚨 CONFIGURATION FIX REQUIRED

## Current Status
✅ **Frontend**: Running on **port 3000 only** (http://localhost:3000)
✅ **Backend**: Running on port 2024
❌ **Configuration**: Router model is **MISCONFIGURED**

## The Problem

Looking at the backend logs, the router model is configured as:
```
openai:lmstudio-local  ❌ WRONG
```

This is being treated as an **OpenAI model** with the API key `lmstudio-local`, which is why you're seeing:
```
401 Incorrect API key provided: lmstudio**ocal
```

## What You Need to Do

### Step 1: Open Settings
Go to: **http://localhost:3000/settings?tab=configuration**

### Step 2: Find Router Model Configuration
Scroll down to find: **`routerModelName`**

### Step 3: Check Current Value
You'll see something like:
- `openai:lmstudio-local` ❌ **WRONG**
- OR `lmstudio-local` ❌ **WRONG**

### Step 4: Fix It
Change it to the **correct format**:

#### Option A: If you know your LM Studio model name
```
lmstudio:your-actual-model-name
```

Example:
- If your LM Studio model is `llama-3.2-3b-instruct`, use: `lmstudio:llama-3.2-3b-instruct`
- If your LM Studio model is `qwen2.5-coder-7b`, use: `lmstudio:qwen2.5-coder-7b`

#### Option B: Use the generic local-model identifier
```
lmstudio:local-model
```

### Step 5: Check Other Model Configurations
Make sure ALL 5 model configurations use the **same format**:

| Config Field | Correct Value |
|--------------|---------------|
| **plannerModelName** | `lmstudio:your-model-name` |
| **programmerModelName** | `lmstudio:your-model-name` |
| **reviewerModelName** | `lmstudio:your-model-name` |
| **routerModelName** | `lmstudio:your-model-name` ← **FIX THIS** |
| **summarizerModelName** | `lmstudio:your-model-name` ← **CHECK THIS** |

### Step 6: Find Your LM Studio Model Name

**Method 1: Check LM Studio UI**
1. Open LM Studio
2. Go to the "Local Server" or "Models" tab
3. Look for the loaded model name
4. Use format: `lmstudio:model-name-from-lmstudio`

**Method 2: Query LM Studio API**
```bash
curl http://127.0.0.1:1234/v1/models
```

This will return JSON with the model ID, like:
```json
{
  "data": [
    {
      "id": "llama-3.2-3b-instruct",
      ...
    }
  ]
}
```

Use: `lmstudio:llama-3.2-3b-instruct`

## Why This Happened

When you configured the models in the UI, you might have used:
- `openai:lmstudio-local` ← Treated as OpenAI model
- `lmstudio-local` ← Missing the provider prefix

The correct format is:
- `lmstudio:model-name` ← Correct!

The `lmstudio:` prefix tells OpenSWE to use the LM Studio provider, not OpenAI.

## After Fixing

1. **Save the configuration** (auto-saves in the UI)
2. **Refresh the page**: `Ctrl + Shift + R` (hard refresh)
3. **Go to main page**: http://localhost:3000
4. **Select repository and branch**
5. **Submit a test task**: "Add a comment to README.md"
6. **Check backend logs** (Terminal 1) - should NOT see API key errors

## Expected Backend Logs (After Fix)

You should see:
```
[ModelManager] Loading model for task router
[ModelManager] Using provider: lmstudio
[ModelManager] Model: your-model-name
✓ Successfully connected to LM Studio
```

NOT:
```
[FallbackRunnable] openai:lmstudio-local failed: 401 Incorrect API key ❌
```

## Verification Checklist

- [ ] Frontend running on **port 3000 only**
- [ ] Settings → Configuration shows **5 model configs**
- [ ] All 5 configs use format: `lmstudio:model-name`
- [ ] Router model is NOT `openai:lmstudio-local`
- [ ] Test task submitted
- [ ] Backend logs show LM Studio connections (no 401 errors)
- [ ] Task completes successfully

## Common Mistakes

### ❌ Wrong Formats
```
openai:lmstudio-local          ← Treated as OpenAI
lmstudio-local                 ← Missing provider prefix
lm-studio:local-model          ← Wrong provider name (hyphen)
lmstudio:                      ← Missing model name
```

### ✅ Correct Formats
```
lmstudio:local-model           ← Generic local model
lmstudio:llama-3.2-3b-instruct ← Specific model
lmstudio:qwen2.5-coder-7b      ← Another specific model
```

## Troubleshooting

### Issue: "I fixed it but still getting errors"

**Solution 1: Hard refresh the browser**
```
Ctrl + Shift + R (Windows/Linux)
Cmd + Shift + R (Mac)
```

**Solution 2: Clear browser localStorage**
```
F12 → Console → Type:
localStorage.clear()
location.reload()
```

**Solution 3: Check LM Studio is running**
```bash
curl http://127.0.0.1:1234/v1/models
# Should return model list, not connection refused
```

### Issue: "I don't know my model name"

**Solution: Use the generic identifier**
```
lmstudio:local-model
```

This works with any model loaded in LM Studio.

### Issue: "Multiple models in LM Studio"

**Solution: Use the currently loaded model**
- Open LM Studio
- Check which model is currently loaded in the server
- Use that model's name with `lmstudio:` prefix

## Quick Fix Summary

1. **Go to**: http://localhost:3000/settings?tab=configuration
2. **Find**: `routerModelName` and `summarizerModelName`
3. **Change to**: `lmstudio:local-model` (or your specific model name)
4. **Hard refresh**: `Ctrl + Shift + R`
5. **Test**: Submit a task at http://localhost:3000

---

**Current Status**: 
- ✅ Frontend: http://localhost:3000 (single port)
- ✅ Backend: http://127.0.0.1:2024 (running)
- ⚠️ **Action Required**: Fix router/summarizer model configuration

**Next Step**: Fix the configuration, then test!

