# 🚀 Quick Start - OpenSWE with LM Studio

## ✅ **Current Status**

**FIXED**: Backend HTTP 500 errors resolved!

**Running**:
- Backend: `http://localhost:2024` ✅
- Frontend: `http://localhost:3004` ✅
- LM Studio: `http://localhost:1234/v1` ✅

---

## 🎯 **Start OpenSWE (Single Command)**

```bash
./start-openswe.sh
```

That's it! The script will:
- ✅ Kill old processes
- ✅ Build packages
- ✅ Generate encryption key
- ✅ Start backend with local mode
- ✅ Start frontend
- ✅ Show you the URLs

---

## 🌐 **Access the Application**

After the script completes:

1. **Open Browser**: `http://localhost:3004` (or shown port)
2. **Sign in with GitHub**
3. **Select Repository**: `zakaseb/temperature_prediction`
4. **Select Branch**: `main`
5. **Submit a Task**: `Show me the contents of README.md`

---

## ⚙️ **Configure Models (One Time)**

1. Go to Settings → Configuration tab
2. Set ALL 5 model dropdowns to: **`LM Studio - openai/gpt-oss-20b`**
   - Planner Model Name
   - Programmer Model Name
   - Reviewer Model Name
   - Router Model Name
   - Summarizer Model Name
3. Click Save

---

## 🛑 **Stop OpenSWE**

```bash
killall -9 node
```

Or use the PIDs shown by the script:
```bash
kill <backend_pid> <frontend_pid>
```

---

## 🔍 **Check Logs**

**Backend:**
```bash
tail -f /tmp/openswe-backend.log
```

**Frontend:**
```bash
tail -f /tmp/openswe-frontend.log
```

---

## ❓ **Troubleshooting**

### **Issue: Can't access frontend**
```bash
# Check if it's running
ss -tulpn | grep next-server
```

### **Issue: Backend not responding**
```bash
# Check if it's running
ss -tulpn | grep 2024

# Check logs
tail -50 /tmp/openswe-backend.log
```

### **Issue: LM Studio not working**
```bash
# Test LM Studio
curl http://localhost:1234/v1/models
```

### **Issue: Port conflicts**
```bash
# Find what's using a port
lsof -i :3000

# Kill it
kill -9 <PID>
```

---

## 📚 **Detailed Documentation**

- `BACKEND_FIX_FINAL.md` - Complete fix explanation
- `ENABLE_LOCAL_MODE.md` - Local mode details
- `SANDBOX_ISSUE_FIX.md` - Sandbox bypass
- `FINAL_STATUS.md` - Overall status

---

## ✨ **What's Working**

✅ Backend starts without errors  
✅ Frontend connects to backend  
✅ LM Studio integration  
✅ Local mode (no Docker needed)  
✅ GitHub OAuth  
✅ Repository/branch selection  
✅ Task submission  
✅ File operations (read/write/edit)  

---

## 🎉 **You're Ready!**

Run `./start-openswe.sh` and start coding! 🚀

---

*For detailed information, see `BACKEND_FIX_FINAL.md`*

