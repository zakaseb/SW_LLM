# ⚡ Quick Configuration Fix (30 seconds)

## The Issue
Your router model is configured as `openai:lmstudio-local` ❌  
It should be `lmstudio:local-model` ✅

## Fix It Now

### 1. Open Settings
http://localhost:3000/settings?tab=configuration

### 2. Find These Fields
- **routerModelName**
- **summarizerModelName**

### 3. Change To
```
lmstudio:local-model
```
(or your specific model name like `lmstudio:llama-3.2-3b-instruct`)

### 4. Hard Refresh
`Ctrl + Shift + R`

### 5. Test
Go to http://localhost:3000 and submit a task

---

## How to Find Your Model Name

### Quick Check
```bash
curl http://127.0.0.1:1234/v1/models
```

Look for the `"id"` field in the response.

### If That Doesn't Work
Use the generic: `lmstudio:local-model`

---

## Correct Format Examples

✅ **Correct**:
- `lmstudio:local-model`
- `lmstudio:llama-3.2-3b-instruct`
- `lmstudio:qwen2.5-coder-7b`

❌ **Wrong**:
- `openai:lmstudio-local` ← Treated as OpenAI!
- `lmstudio-local` ← Missing prefix!
- `lm-studio:model` ← Wrong prefix!

---

## What Changed

✅ **Fixed**: 
- Killed duplicate frontend servers
- Only port 3000 is running now

⚠️ **Your Turn**:
- Fix router model configuration
- Fix summarizer model configuration

---

**Status**: 
- Frontend: http://localhost:3000 ✅
- Backend: http://127.0.0.1:2024 ✅
- Config: **Needs your fix** ⚠️

**Read**: `CONFIGURATION_FIX_REQUIRED.md` for detailed instructions

