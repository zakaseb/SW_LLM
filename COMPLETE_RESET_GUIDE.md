# 🔧 Complete Reset & Configuration Guide

## The Problems

### 1. Circuit Breaker is OPEN
```
[FallbackRunnable] Circuit breaker open for lmstudio:lmstudio-local, skipping
```

**What this means**: 
- `lmstudio:lmstudio-local` failed multiple times
- Backend opened a circuit breaker (blocks for 3 minutes)
- Now it's permanently skipping your LM Studio

### 2. Stale Browser Configuration
Your config is stored in browser localStorage. Even if you selected the new model in the UI, the old config might still be cached.

### 3. Backend Not Fully Restarted
The backend might not have restarted properly with the latest fixes.

---

## 🎯 Complete Reset (5 minutes)

### Step 1: Kill ALL Processes

```bash
# Kill backend
pkill -9 -f "open-swe.*yarn dev"

# Kill frontend  
pkill -9 -f "apps/web.*yarn dev"

# Verify all killed
ss -tulpn | grep -E "(2024|3000|3001)"
```

### Step 2: Clear Browser Storage

**Open Browser Console** (F12) and run:

```javascript
// Clear all OpenSWE storage
localStorage.removeItem('open-swe-config-storage');
localStorage.clear();
sessionStorage.clear();

// Verify it's cleared
console.log("localStorage cleared:", localStorage.length === 0);

// Hard refresh
location.reload(true);
```

### Step 3: Rebuild Everything

```bash
cd /home/precision7780/PycharmProjects/open-swe

# Rebuild shared package
yarn workspace @open-swe/shared build

# Verify build succeeded
ls -la packages/shared/dist/open-swe/types.js
```

### Step 4: Start Backend

```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev
```

**Wait for**:
```
╦  ┌─┐┌┐┌┌─┐╔═╗┬─┐┌─┐┌─┐┬ ┬
║  ├─┤││││ ┬║ ╦├┬┘├─┤├─┘├─┤
╩═╝┴ ┴┘└┘└─┘╚═╝┴└─┴ ┴┴  ┴ ┴.js
- 🚀 API: http://localhost:2024
```

### Step 5: Start Frontend

```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev
```

**Wait for**:
```
▲ Next.js 15.4.1
- Local:        http://localhost:3000
✓ Ready
```

### Step 6: Configure UI (Fresh)

1. **Open**: http://localhost:3000/settings?tab=configuration

2. **Scroll down and configure ALL 5 models:**

   | Field | Select THIS Option |
   |-------|-------------------|
   | `plannerModelName` | **LM Studio - openai/gpt-oss-20b** |
   | `programmerModelName` | **LM Studio - openai/gpt-oss-20b** |
   | `reviewerModelName` | **LM Studio - openai/gpt-oss-20b** |
   | `routerModelName` | **LM Studio - openai/gpt-oss-20b** |
   | `summarizerModelName` | **LM Studio - openai/gpt-oss-20b** |

3. **Verify config was saved**:
   - Open Browser Console (F12)
   - Run:
     ```javascript
     const config = JSON.parse(localStorage.getItem('open-swe-config-storage'));
     console.log("Current Config:", config);
     console.log("Router Model:", config.state.configs.default?.routerModelName);
     ```
   - Should show: `"lmstudio:openai/gpt-oss-20b"`

4. **Hard Refresh**: `Ctrl + Shift + R`

### Step 7: Verify LM Studio

```bash
curl http://localhost:1234/v1/models
```

**Expected**:
```json
{
  "data": [
    {
      "id": "openai/gpt-oss-20b",
      ...
    }
  ]
}
```

### Step 8: Test

1. Go to http://localhost:3000
2. Select repo: `zakaseb/temperature_prediction`
3. Branch: `main`
4. Submit: "What files are in this repository?"

### Step 9: Check Backend Logs

**Terminal 1 should show**:

✅ **Success**:
```
[ModelManager] Loading model for task router
[ModelManager] Using provider: lmstudio
[ModelManager] Model: openai/gpt-oss-20b
[FallbackRunnable] Converting tool_choice to "required" for LM Studio
✓ Connected to LM Studio
```

❌ **Still Wrong**:
```
[FallbackRunnable] lmstudio:lmstudio-local failed...
[FallbackRunnable] Circuit breaker open for lmstudio:lmstudio-local
```

---

## 🔍 Debugging Commands

### Check Current Config in Browser

```javascript
// Get stored config
const storage = localStorage.getItem('open-swe-config-storage');
const config = JSON.parse(storage);

console.log("=== Configuration Debug ===");
console.log("Planner:", config.state.configs.default?.plannerModelName);
console.log("Programmer:", config.state.configs.default?.programmerModelName);
console.log("Reviewer:", config.state.configs.default?.reviewerModelName);
console.log("Router:", config.state.configs.default?.routerModelName);
console.log("Summarizer:", config.state.configs.default?.summarizerModelName);

// All should be: "lmstudio:openai/gpt-oss-20b"
```

### Check Backend Process

```bash
# Find backend PID
ps aux | grep "open-swe.*yarn dev" | grep -v grep

# Check if port 2024 is listening
ss -tulpn | grep 2024

# Test backend
curl -X GET http://localhost:2024/ok
```

### Check Frontend Process

```bash
# Find frontend PID
ps aux | grep "apps/web.*yarn dev" | grep -v grep

# Check if port 3000 is listening
ss -tulpn | grep 3000

# Test frontend
curl -X GET http://localhost:3000
```

### Check Circuit Breaker State

Backend logs will show:
```
[ModelManager] <provider>:<model>: Circuit breaker opened after 2 failures
[ModelManager] <provider>:<model>: Circuit breaker automatically recovered: OPEN → CLOSED
```

Circuit breaker recovers after 3 minutes (180 seconds).

---

## 🚨 Common Issues

### Issue 1: "Circuit breaker open"

**Cause**: Previous failures opened the circuit breaker

**Solution**: 
1. Wait 3 minutes for auto-recovery, OR
2. Restart backend (clears circuit breaker state)

### Issue 2: "Still using old model"

**Cause**: Config not saved or not loaded

**Solution**:
1. Clear localStorage (see Step 2)
2. Re-configure (see Step 6)
3. Verify config (see Step 6.3)

### Issue 3: "Invalid tool_choice type"

**Cause**: Backend not running latest code with fix

**Solution**:
1. Verify tool_choice fix exists:
   ```bash
   grep -A 10 "LM Studio only supports" apps/open-swe/src/utils/runtime-fallback.ts
   ```
2. If not found, the fix isn't applied
3. Restart backend

### Issue 4: "Cannot find module"

**Cause**: Shared package not built

**Solution**:
```bash
cd /home/precision7780/PycharmProjects/open-swe
yarn workspace @open-swe/shared build
```

---

## ✅ Final Verification Checklist

After complete reset:

- [ ] All processes killed
- [ ] Browser localStorage cleared
- [ ] Shared package rebuilt successfully
- [ ] Backend running on port 2024
- [ ] Frontend running on port 3000
- [ ] LM Studio running on port 1234
- [ ] Model `openai/gpt-oss-20b` loaded in LM Studio
- [ ] All 5 models configured to "LM Studio - openai/gpt-oss-20b"
- [ ] Config verified in browser console
- [ ] Hard refreshed browser
- [ ] Test task submitted
- [ ] Backend logs show: `Using provider: lmstudio`
- [ ] Backend logs show: `Model: openai/gpt-oss-20b`
- [ ] Backend logs show: `Converting tool_choice to "required"`
- [ ] NO circuit breaker errors
- [ ] Task completes successfully

---

## 📊 Expected vs Actual

### ✅ What You Should See

**Browser Console**:
```javascript
routerModelName: "lmstudio:openai/gpt-oss-20b"
```

**Backend Logs**:
```
[ModelManager] Using provider: lmstudio
[ModelManager] Model: openai/gpt-oss-20b
✓ Task router executing
```

**Frontend**:
```
Task submitted successfully
Planner: Working...
```

### ❌ What You're Seeing Now

**Browser Console**:
```javascript
routerModelName: "lmstudio:lmstudio-local" // WRONG!
```

**Backend Logs**:
```
[FallbackRunnable] Circuit breaker open for lmstudio:lmstudio-local
All fallback models exhausted for task router
```

**Frontend**:
```
An error occurred: All fallback models exhausted
```

---

## 🎯 Root Cause Analysis

### Why This Happened

1. **Initial Config**: You selected "LM Studio Local (Generic)" → `lmstudio:lmstudio-local`
2. **Model Mismatch**: LM Studio doesn't have a model called `lmstudio-local`
3. **Failures**: Multiple requests failed
4. **Circuit Breaker**: Backend opened circuit breaker, blocking further attempts
5. **New Config**: You selected "LM Studio - openai/gpt-oss-20b"
6. **BUT**: Browser cache still had old config
7. **Result**: Backend still trying old model, circuit breaker still open

### Why Reset Fixes It

1. **Kill processes**: Clears circuit breaker state in backend
2. **Clear localStorage**: Removes stale config from browser
3. **Rebuild**: Ensures latest code (with tool_choice fix)
4. **Fresh config**: New configuration without cache
5. **Success**: Clean slate, correct model, no circuit breaker blocks

---

**Start Here**: Run Step 1 (Kill ALL Processes) now! 🚀

