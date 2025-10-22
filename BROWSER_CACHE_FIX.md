# 🔧 CRITICAL FIX: Browser Cache Issue

## 🔴 **Your Problem**

### **Errors**:
1. `HTTP 404: Thread with ID 31406d39-7c69-437a-9d92-a5bfb2c242af not found`
2. `All fallback models exhausted for task router. Last error: undefined`

### **Root Cause**:
Your browser's **localStorage** is storing **OLD configurations** from before we fixed the model defaults. When you try to create a new thread, the UI sends these old configurations (Anthropic models) to the backend, which fails because you don't have API keys.

---

## ✅ **The Solution: Complete Browser Reset**

### **Step 1: Close ALL Browser Tabs** for `localhost:3000`

### **Step 2: Open DevTools and Clear Everything**
1. Open a NEW tab: `http://localhost:3000`
2. Press `F12` to open DevTools
3. Go to **Application** tab
4. Click **Clear site data** (top right)
5. Ensure ALL checkboxes are checked:
   - ✅ Cookies and other site data
   - ✅ Cached images and files
   - ✅ Storage (Local Storage, Session Storage, etc.)
6. Click **Clear data**

### **Step 3: Manual Verification**
In DevTools → Application:
1. **Local Storage** → `http://localhost:3000`
   - Find `open-swe-config-storage`
   - Click it → Click **Delete** (trash icon)
2. **Session Storage** → `http://localhost:3000`
   - Delete ALL entries
3. **Cookies** → `http://localhost:3000`
   - Delete ALL cookies

### **Step 4: Hard Refresh**
- Press `Ctrl+Shift+R` (Linux/Windows)
- Or `Cmd+Shift+R` (Mac)

### **Step 5: Sign In Fresh**
1. Click **"Sign in with GitHub"**
2. Authorize
3. You'll be redirected back

### **Step 6: Verify Configuration**
1. Go to: `http://localhost:3000/settings?tab=configuration`
2. Check that ALL 5 models show: **"LM Studio - openai/gpt-oss-20b"**
   - Router Model
   - Summarizer Model
   - Planner Model
   - Programmer Model
   - Reviewer Model

**If they don't**, the browser cache wasn't fully cleared. Repeat Steps 2-4.

**If they do**, you're ready to test!

---

## 🧪 **Testing**

### **Test 1: Create a New Thread**
1. Go to: `http://localhost:3000`
2. Select repository: `zakaseb/temperature_prediction`
3. Select branch: `main`
4. Type: `"Show me the contents of README.md"`
5. Click **Submit**

### **Expected Result**:
✅ Thread created successfully (no 404)  
✅ Planner starts  
✅ Router works  
✅ No API key errors  

### **If you still get errors**:
Check the backend logs:
```bash
tail -f /tmp/backend-latest-*.log | grep -E "error|Error|fallback|Fallback"
```

---

## 🔍 **Why This Happened**

### **The Timeline**:
1. **Initial state**: All models defaulted to Anthropic
2. **You tested**: System tried Anthropic → No API key → Failed
3. **Browser cached**: The Anthropic configuration in localStorage
4. **We fixed**: Changed all defaults to LM Studio
5. **You tested again**: Browser STILL used old cached Anthropic config
6. **Result**: Router still tried Anthropic → Failed

### **The Fix**:
By clearing browser cache, the UI will use the NEW defaults (LM Studio) for all models.

---

## 📋 **About the 404 Errors**

### **Old Threads**:
Threads like `31406d39-7c69-437a-9d92-a5bfb2c242af` were created with **bad configurations** (using Anthropic models without API keys). They **failed during creation** and were never properly stored.

### **Solution**:
**Ignore them**. They're dead threads. Create a **new thread** after clearing browser cache, and it will work.

---

## 🎯 **Current System Status**

### **Backend**:
✅ Running on port 2024 (PID: 914074)  
✅ Using latest code  
✅ All model defaults → LM Studio  

### **LM Studio**:
✅ Running on port 1234  
✅ Model `openai/gpt-oss-20b` loaded  
✅ Responding to requests  

### **Configuration Defaults** (Backend):
```
Router:      lmstudio:openai/gpt-oss-20b
Summarizer:  lmstudio:openai/gpt-oss-20b
Planner:     lmstudio:openai/gpt-oss-20b
Programmer:  lmstudio:openai/gpt-oss-20b
Reviewer:    lmstudio:openai/gpt-oss-20b
```

### **What YOU need to do**:
Clear browser cache so the UI uses these defaults!

---

## ⚠️ **IMPORTANT NOTES**

### **1. Old Threads Will Always 404**
Any thread created before clearing browser cache will fail. **Don't try to access them**.

### **2. Always Clear Cache After Code Changes**
Whenever we update model defaults or configuration schema, you MUST clear browser cache.

### **3. Check Configuration After Cache Clear**
Always verify in Settings that all models show "LM Studio - openai/gpt-oss-20b".

---

## 🚀 **Quick Checklist**

Before testing:
- [ ] Backend running on port 2024
- [ ] LM Studio running on port 1234
- [ ] Model `openai/gpt-oss-20b` loaded in LM Studio
- [ ] Browser cache cleared (localStorage + cookies + sessionStorage)
- [ ] Hard refresh done
- [ ] Signed in to GitHub
- [ ] All 5 models in Settings show "LM Studio - openai/gpt-oss-20b"

Then:
- [ ] Create new thread
- [ ] Submit a simple task
- [ ] Watch it work!

---

## 📝 **If You Still Have Issues**

Run this diagnostic:
```bash
# Check backend
ss -tulpn | grep 2024

# Check LM Studio
curl -s http://localhost:1234/v1/models | jq -r '.data[].id'

# Watch backend logs
tail -f /tmp/backend-latest-*.log
```

Open browser DevTools Console and look for:
- Configuration being used
- API requests being made
- Error messages

---

**Last Updated**: October 22, 2025  
**Status**: ✅ Backend ready, LM Studio ready, waiting for browser cache clear

