# ⚡ START HERE - Quick Fix

## The Problem

You're stuck in a loop of errors because:
1. **Circuit Breaker is OPEN** - Backend blocked `lmstudio:lmstudio-local` due to previous failures
2. **Stale Config** - Browser has old configuration in localStorage
3. **Need Fresh Start** - Everything needs to be reset

---

## ⚡ Quick Fix (2 commands)

### Option 1: Automated Script

```bash
cd /home/precision7780/PycharmProjects/open-swe
./reset-and-start.sh
```

Then follow the on-screen instructions to:
1. Clear browser localStorage
2. Configure models
3. Test!

### Option 2: Manual (If script fails)

#### 1. Kill Everything
```bash
pkill -9 -f "yarn dev"
```

#### 2. Rebuild
```bash
cd /home/precision7780/PycharmProjects/open-swe
yarn workspace @open-swe/shared build
```

#### 3. Start Backend
```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev &
sleep 10
```

#### 4. Start Frontend
```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev &
sleep 10
```

---

## 🌐 Browser Steps (CRITICAL!)

### 1. Clear localStorage

**Open** http://localhost:3000

**Press F12** → Console → **Paste and Run**:

```javascript
localStorage.removeItem('open-swe-config-storage');
localStorage.clear();
sessionStorage.clear();
console.log("✓ Storage cleared!");
location.reload(true);
```

### 2. Configure Models

**Go to**: http://localhost:3000/settings?tab=configuration

**Scroll down and find these 5 dropdowns**:

- `plannerModelName`
- `programmerModelName`
- `reviewerModelName`
- `routerModelName` ← **This one is critical**
- `summarizerModelName`

**For EACH dropdown, select**:
```
LM Studio - openai/gpt-oss-20b
```

(NOT "LM Studio Local (Generic)" - that's the old one!)

### 3. Verify Config Saved

**Press F12** → Console → **Paste and Run**:

```javascript
const config = JSON.parse(localStorage.getItem('open-swe-config-storage'));
const defaultConfig = config?.state?.configs?.default || {};

console.log("=== Configuration Verification ===");
console.log("Planner:    ", defaultConfig.plannerModelName);
console.log("Programmer: ", defaultConfig.programmerModelName);
console.log("Reviewer:   ", defaultConfig.reviewerModelName);
console.log("Router:     ", defaultConfig.routerModelName);      // Should be: lmstudio:openai/gpt-oss-20b
console.log("Summarizer: ", defaultConfig.summarizerModelName);  // Should be: lmstudio:openai/gpt-oss-20b

// All should say: "lmstudio:openai/gpt-oss-20b"
if (defaultConfig.routerModelName === "lmstudio:openai/gpt-oss-20b") {
    console.log("✅ Configuration is CORRECT!");
} else {
    console.log("❌ Configuration is WRONG! Expected: lmstudio:openai/gpt-oss-20b, Got:", defaultConfig.routerModelName);
}
```

### 4. Hard Refresh

`Ctrl + Shift + R`

---

## 🧪 Test

1. Go to http://localhost:3000
2. Select repo: `zakaseb/temperature_prediction`
3. Branch: `main`
4. Submit: "List the files in this repository"

---

## ✅ Success Indicators

### Backend Logs (Terminal running backend)

**Look for**:
```
[ModelManager] Using provider: lmstudio
[ModelManager] Model: openai/gpt-oss-20b
[FallbackRunnable] Converting tool_choice to "required" for LM Studio
```

**Should NOT see**:
```
❌ Circuit breaker open for lmstudio:lmstudio-local
❌ All fallback models exhausted
❌ Invalid tool_choice type: 'object'
```

### Frontend

**Should show**:
```
✅ Task submitted successfully
✅ Manager: Running...
✅ Planner: Working...
```

**Should NOT see**:
```
❌ An error occurred: All fallback models exhausted
❌ Failed to start task
```

---

## 🚨 If It Still Fails

### Check 1: Is LM Studio Running?

```bash
curl http://localhost:1234/v1/models
```

Should return:
```json
{"data":[{"id":"openai/gpt-oss-20b",...}]}
```

If not:
1. Open LM Studio
2. Go to "Local Server" tab
3. Start server on port 1234
4. Load model: `openai/gpt-oss-20b`

### Check 2: Is Config Really Correct?

Run the verification script in browser console (Step 3 above).

If it shows wrong model:
1. Go back to settings
2. Re-select "LM Studio - openai/gpt-oss-20b" for ALL 5
3. Verify again

### Check 3: Are Services Running?

```bash
# Backend
curl http://localhost:2024/ok

# Frontend
curl http://localhost:3000

# If either fails, check logs
tail -f /tmp/openswe-backend.log
tail -f /tmp/openswe-frontend.log
```

---

## 📚 Detailed Documentation

- **Complete Reset Guide**: `COMPLETE_RESET_GUIDE.md`
- **Tool Choice Fix**: `TOOL_CHOICE_FIX.md`
- **Model Configuration**: `FINAL_FIX_GUIDE.md`

---

## 🎯 Quick Checklist

- [ ] Ran `./reset-and-start.sh` OR killed processes manually
- [ ] Cleared browser localStorage
- [ ] Configured ALL 5 models to "LM Studio - openai/gpt-oss-20b"
- [ ] Verified config in console (shows `lmstudio:openai/gpt-oss-20b`)
- [ ] Hard refreshed browser
- [ ] LM Studio is running with `openai/gpt-oss-20b`
- [ ] Backend shows: `Using provider: lmstudio`
- [ ] Submitted test task
- [ ] Task succeeded!

---

**Run this now**: `./reset-and-start.sh` 🚀

Then follow the browser steps above!

