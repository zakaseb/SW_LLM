# 🚀 Starting OpenSWE with `yarn dev` (Manual Method)

## ✅ **FIXED**: Backend `.env` now has all required variables!

---

## 🔧 **What Was Missing**

Your `apps/open-swe/.env` file was missing:
```
SECRETS_ENCRYPTION_KEY=<encryption-key>
```

This caused **HTTP 500 errors** because the authentication middleware couldn't encrypt/decrypt credentials.

**Now Fixed**: ✅ Encryption key added to `.env` file

---

## 📋 **How to Start with `yarn dev`**

### **Terminal 1: Start Backend**
```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev
```

**Wait for**: `Starting 10 workers` message (takes ~15 seconds)

### **Terminal 2: Start Frontend**
```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev
```

**Wait for**: `Ready in Xms` message (takes ~15-20 seconds)

**Frontend will be on**: `http://localhost:3000` (or next available port like 3001, 3002, etc.)

---

## ✅ **Verification**

### **Check Backend is Running:**
```bash
ss -tulpn | grep 2024
# Should show: tcp LISTEN ... 127.0.0.1:2024
```

### **Check Frontend is Running:**
```bash
ss -tulpn | grep next-server
# Should show: tcp LISTEN ... *:3000 (or 3001, 3002, etc.)
```

### **Test Backend Health:**
```bash
curl -I http://localhost:2024/ok
# Should return: HTTP/1.1 401 Unauthorized (this is CORRECT!)
```

---

## 🌐 **Access the Application**

1. **Open Browser**: Check frontend terminal for the URL (e.g., `http://localhost:3002`)
2. **Sign in with GitHub**
3. **Configure Models** (first time only):
   - Go to Settings → Configuration
   - Set ALL 5 dropdowns to: `LM Studio - openai/gpt-oss-20b`
   - Click Save
4. **Select Repository**: `zakaseb/temperature_prediction`
5. **Select Branch**: `main`
6. **Submit Task**: `Show me the contents of README.md`

---

## 📝 **Current Backend `.env` File**

```env
# Enable Local Mode (works with local filesystem, no Docker/Daytona needed)
OPEN_SWE_LOCAL_MODE=true

# LM Studio API URL
LMSTUDIO_BASE_URL=http://localhost:1234/v1

# GitHub App Configuration (required even in local mode for backend to start)
# These are dummy values since webhooks are not used in local mode
GITHUB_APP_ID=123456
GITHUB_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA0Z2Z... (dummy key)\n-----END RSA PRIVATE KEY-----"
GITHUB_WEBHOOK_SECRET=dummy_webhook_secret_for_local_mode

# Authentication encryption key (REQUIRED - added by fix)
SECRETS_ENCRYPTION_KEY=<your-32-byte-hex-key>
```

**Location**: `/home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env`

---

## 🚨 **Troubleshooting**

### **Issue: Backend shows "Missing SECRETS_ENCRYPTION_KEY"**

This should NOT happen anymore since I added it to the `.env` file. But if it does:

```bash
# Verify the .env file has the key
cat /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env | grep SECRETS_ENCRYPTION_KEY

# If missing, regenerate:
echo "SECRETS_ENCRYPTION_KEY=$(openssl rand -hex 32)" >> /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env
```

### **Issue: HTTP 500 errors in browser**

**Check Backend Logs**:
```bash
# Look for errors in the terminal where you ran 'yarn dev'
# Or check for "error" or "Error" messages
```

**Common causes**:
1. Backend not fully started yet (wait for "Starting 10 workers")
2. LM Studio not running (start LM Studio and load model)
3. Port 2024 blocked (kill other processes: `lsof -i :2024`)

### **Issue: Frontend shows "Cannot connect to backend"**

**Verify backend is running**:
```bash
curl http://localhost:2024/ok
# Should return 401 (not 500!)
```

**Check frontend .env**:
```bash
cat /home/precision7780/PycharmProjects/open-swe/apps/web/.env | grep NEXT_PUBLIC_API_URL
# Should be: NEXT_PUBLIC_API_URL="/api"
```

### **Issue: LM Studio errors (model not found, connection refused)**

```bash
# Test LM Studio connectivity
curl http://localhost:1234/v1/models

# If empty or error:
# 1. Open LM Studio application
# 2. Load model: openai/gpt-oss-20b
# 3. Enable local server (port 1234)
```

### **Issue: Multiple frontend ports (3000, 3001, 3002...)**

This happens when you start frontend multiple times. Frontend will automatically use the next available port.

**To clean up**:
```bash
killall -9 node
sleep 3
# Then start backend and frontend again
```

---

## 🔄 **Restart Process**

If you need to restart:

1. **Stop Both Services**: Press `Ctrl+C` in both terminal windows (or `killall -9 node`)
2. **Start Backend**: `cd apps/open-swe && yarn dev`
3. **Wait 15 seconds**
4. **Start Frontend**: `cd apps/web && yarn dev`
5. **Wait for "Ready in Xms"**
6. **Access at shown URL**

---

## 📊 **What's Different from the Startup Script**

| Method | `./start-openswe.sh` | `yarn dev` manually |
|--------|---------------------|---------------------|
| Cleanup | Automatic | Manual (`killall -9 node`) |
| Package builds | Automatic | Manual if needed |
| Env vars | Set in command | Read from `.env` files |
| Status display | Automatic | Manual verification |
| Ease of use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Flexibility | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Both methods work!** Choose based on your preference:
- **Script**: Better for quick starts and clean environments
- **`yarn dev`**: Better for development with hot reload and debugging

---

## ✅ **Summary of Fix**

**Problem**: Missing `SECRETS_ENCRYPTION_KEY` in backend `.env` file  
**Symptom**: HTTP 500 errors on all API requests  
**Solution**: Added encryption key to `apps/open-swe/.env`  
**Result**: ✅ `yarn dev` now works in both directories without errors

---

## 🎯 **Next Steps**

1. **Start Backend**: Terminal 1 → `cd apps/open-swe && yarn dev`
2. **Start Frontend**: Terminal 2 → `cd apps/web && yarn dev`
3. **Open Browser**: Use URL from frontend terminal
4. **Configure Models**: Set all 5 to LM Studio (one-time)
5. **Test**: Submit a prompt and verify it works!

---

## 📚 **Related Documentation**

- `START_HERE_FINAL.md` - Overall quick start
- `BACKEND_FIX_FINAL.md` - Technical details of the fix
- `QUICK_START.md` - Quick reference
- `COMPLETE_STATUS.md` - System overview
- This file - Manual `yarn dev` method

---

**Status**: ✅ **READY TO USE WITH `yarn dev`**

*The `.env` file is now properly configured. You can start both services with `yarn dev` and the system will work end-to-end!* 🚀

