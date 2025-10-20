# Backend Error Fixed - Comprehensive Documentation

## 🔴 **Original Error**

**Browser Console:**
```
Submit Error] Error: HTTP 500: Internal Server Error
```

**UI:**
```
HTTP 500: Internal Server Error
```

**Backend Terminal:**
```
error: ▪ Error: listen EADDRINUSE: address already in use 127.0.0.1:2024
```

**Backend Logs (when accessible):**
```
Error: Missing SECRETS_ENCRYPTION_KEY environment variable.
```

---

## 🔍 **Root Causes Identified**

### 1. **Multiple Backend Instances Conflict**
- **Issue**: Multiple `yarn dev` processes were running simultaneously
- **Symptom**: `EADDRINUSE` error - port 2024 already in use
- **Impact**: New backend instances couldn't start, old instances kept running with outdated code

### 2. **Missing Environment Variable**
- **Issue**: `SECRETS_ENCRYPTION_KEY` was not set
- **Required For**: Authentication/authorization middleware
- **Impact**: All API requests returned HTTP 500 errors
- **Location**: `apps/open-swe/src/security/auth.ts:88`

### 3. **Outdated Running Instance**
- **Issue**: The running backend didn't have the GitHub App fix
- **Impact**: Backend would crash if GitHub webhooks were configured
- **Solution**: Needed full rebuild and restart with all fixes

### 4. **Missing Shared Package Build**
- **Issue**: Frontend showed `packages/shared/dist/constants.js` missing
- **Impact**: Frontend compilation errors
- **Solution**: Rebuild shared package before starting apps

---

## ✅ **Complete Solution**

### **Created: `start-openswe.sh` - Comprehensive Startup Script**

This script handles EVERYTHING needed to run OpenSWE properly:

#### **What It Does:**

1. **Cleanup Phase**
   - Kills ALL existing node processes
   - Ensures no port conflicts
   - Clean slate for new start

2. **Build Phase**
   - Builds `@open-swe/shared` package first (dependency)
   - Builds `@open-swe/agent` package with all latest fixes
   - Ensures compiled code includes all modifications

3. **Security Setup**
   - Generates random 32-byte encryption key
   - Required for authentication middleware
   - Unique per startup for security

4. **LM Studio Check**
   - Verifies LM Studio is running on port 1234
   - Checks if model is loaded
   - Warns user if not available

5. **Backend Startup**
   - Sets environment variables:
     - `OPEN_SWE_LOCAL_MODE=true` (bypass Docker/Daytona)
     - `LMSTUDIO_BASE_URL=http://localhost:1234/v1`
     - `SECRETS_ENCRYPTION_KEY=<generated>`
   - Logs to `/tmp/openswe-backend.log`
   - Waits for port 2024 to be listening
   - Verifies successful startup

6. **Frontend Startup**
   - Starts Next.js on available port (3000-3004)
   - Logs to `/tmp/openswe-frontend.log`
   - Waits for "Ready" status
   - Displays actual port used

7. **Status Summary**
   - Shows all access URLs
   - Displays process IDs for management
   - Provides log file locations
   - Shows stop commands
   - Lists next steps for user

---

## 📋 **Usage Instructions**

### **Quick Start:**
```bash
./start-openswe.sh
```

### **Manual Process (if needed):**

```bash
# 1. Kill all processes
killall -9 node && sleep 3

# 2. Build packages
cd /home/precision7780/PycharmProjects/open-swe
yarn workspace @open-swe/shared build
yarn workspace @open-swe/agent build

# 3. Generate encryption key
ENCRYPTION_KEY=$(openssl rand -hex 32)

# 4. Start backend
OPEN_SWE_LOCAL_MODE=true \
LMSTUDIO_BASE_URL=http://localhost:1234/v1 \
SECRETS_ENCRYPTION_KEY=$ENCRYPTION_KEY \
yarn workspace @open-swe/agent dev > /tmp/openswe-backend.log 2>&1 &

# 5. Wait 15 seconds, then start frontend
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev > /tmp/openswe-frontend.log 2>&1 &
```

---

## 🎯 **Testing the Fix**

### **1. Verify Backend is Running:**
```bash
ss -tulpn | grep 2024
# Should show: tcp LISTEN ... 127.0.0.1:2024
```

### **2. Check Backend Health:**
```bash
curl -I http://localhost:2024/ok
# Should return: HTTP/1.1 401 Unauthorized
# (401 is CORRECT - means auth is working, just need to authenticate)
```

### **3. Check Backend Logs:**
```bash
tail -f /tmp/openswe-backend.log
# Should show: "Starting 10 workers" with NO errors
```

### **4. Check Frontend:**
```bash
ss -tulpn | grep next-server
# Should show frontend on one port only
```

### **5. Test in Browser:**
1. Open `http://localhost:3004` (or shown port)
2. Sign in with GitHub
3. Select repository: `zakaseb/temperature_prediction`
4. Branch: `main`
5. Submit prompt: `Show me the contents of README.md`
6. **Expected**: Task should start without HTTP 500 errors

---

## 🔧 **Environment Variables Explained**

### **Required for Backend:**

| Variable | Purpose | Value | When Set |
|----------|---------|-------|----------|
| `OPEN_SWE_LOCAL_MODE` | Skip Docker/Daytona sandbox | `true` | Startup |
| `LMSTUDIO_BASE_URL` | LM Studio API endpoint | `http://localhost:1234/v1` | Startup |
| `SECRETS_ENCRYPTION_KEY` | Auth encryption key | Random 32-byte hex | Startup (auto-generated) |

### **Optional (GitHub Integration):**

| Variable | Purpose | Source |
|----------|---------|--------|
| `GITHUB_APP_ID` | GitHub App ID | GitHub App settings |
| `GITHUB_APP_PRIVATE_KEY` | GitHub App private key | GitHub App settings |
| `GITHUB_WEBHOOK_SECRET` | Webhook secret | GitHub App settings |

**Note**: GitHub webhook variables are now OPTIONAL due to the fix in `apps/open-swe/src/utils/github-app.ts` that allows the app to run without them.

---

## 📊 **What Was Fixed in Code**

### **1. GitHub App Initialization** (`apps/open-swe/src/utils/github-app.ts`)

**Before:**
```typescript
if (!appId || !privateKey || !webhookSecret) {
  throw new Error("GitHub App ID, Private Key, or Webhook Secret is not configured.");
}
```

**After:**
```typescript
if (!appId || !privateKey || !webhookSecret) {
  logger.debug(
    "GitHub App credentials not fully configured. GitHub webhook functionality will be limited."
  );
  return null; // Return null instead of crashing
}
```

**Why**: Allows backend to start even without GitHub webhook setup (only needed for automated PR/issue workflows, not for manual UI usage).

### **2. Startup Script** (`start-openswe.sh`)

**Created**: Comprehensive automation for:
- Process cleanup
- Package building
- Environment variable setup
- Service startup with health checks
- Status reporting

**Why**: Eliminates manual errors and ensures consistent startup process.

---

## 🚨 **Common Issues & Solutions**

### **Issue: Port 3000 already in use**
**Solution**: Script automatically uses next available port (3001, 3002, etc.)
```bash
# Find what's using port 3000
lsof -i :3000
# Kill it if needed
kill -9 <PID>
```

### **Issue: LM Studio not responding**
**Symptoms**: Errors about model not found, connection refused
**Solution**:
1. Start LM Studio application
2. Load model: `openai/gpt-oss-20b`
3. Ensure local server is running on port 1234
4. Test: `curl http://localhost:1234/v1/models`

### **Issue: Backend shows "listen EADDRINUSE"**
**Solution**: Use the startup script which kills all processes first
```bash
./start-openswe.sh
```

### **Issue: Frontend shows shared package errors**
**Symptoms**: `Cannot find module '../../packages/shared/dist/constants.js'`
**Solution**: Rebuild shared package
```bash
yarn workspace @open-swe/shared build
```

---

## 📝 **Log Files**

### **Backend Log:**
```bash
tail -f /tmp/openswe-backend.log
```
**Look For:**
- `Starting 10 workers` ✅
- No errors about missing environment variables ✅
- No `EADDRINUSE` errors ✅

### **Frontend Log:**
```bash
tail -f /tmp/openswe-frontend.log
```
**Look For:**
- `Ready in Xms` ✅
- `Local: http://localhost:XXXX` ✅
- No webpack errors ✅

---

## ✨ **Verification Checklist**

After running `./start-openswe.sh`, verify:

- [ ] Backend PID displayed and process is running
- [ ] Frontend PID displayed and process is running
- [ ] Port 2024 is listening (backend)
- [ ] Frontend port (3000-3004) is listening
- [ ] Backend logs show "Starting 10 workers"
- [ ] Backend logs show NO errors
- [ ] Frontend logs show "Ready in Xms"
- [ ] Browser can access frontend URL
- [ ] Can sign in with GitHub
- [ ] Can select repository and branch
- [ ] Submit button is enabled
- [ ] Submitting task does NOT show HTTP 500 error

---

## 🎉 **Success Indicators**

### **Backend Terminal:**
```
info:    ▪ Starting 10 workers
```
✅ **No errors after this line**

### **Browser Console:**
✅ **No "HTTP 500" errors when submitting**
✅ **No "URL constructor" errors**
✅ **No "Missing encryption key" errors**

### **Backend Logs:**
```bash
tail -50 /tmp/openswe-backend.log | grep -i error
# Should output: "✅ No errors in backend logs"
```

---

## 🚀 **Next Steps After Fix**

1. **Test Basic Functionality:**
   - Prompt: `Show me the contents of README.md`
   - Should display file contents

2. **Test Edit Functionality:**
   - Prompt: `Add a comment to the top of README.md`
   - Should create plan, execute, and show results

3. **Configure UI Settings:**
   - Go to Settings → Configuration
   - Ensure all 5 model dropdowns set to: `LM Studio - openai/gpt-oss-20b`
   - Save configuration

4. **Monitor Logs During Task:**
   ```bash
   # Terminal 1: Backend
   tail -f /tmp/openswe-backend.log | grep -v "GET /ok"
   
   # Terminal 2: Frontend
   tail -f /tmp/openswe-frontend.log
   ```

---

## 📚 **Related Documentation**

- `ENABLE_LOCAL_MODE.md` - How local mode works
- `SANDBOX_ISSUE_FIX.md` - Sandbox bypass details
- `FINAL_STATUS.md` - Overall project status
- `start-openswe.sh` - Automated startup script

---

## 🔒 **Security Notes**

1. **Encryption Key**: Generated fresh on each startup
   - Not persisted to disk
   - Unique per session
   - Secure random generation via `openssl`

2. **GitHub OAuth**: Still requires proper OAuth app setup
   - Callback URL must be whitelisted
   - See `GITHUB_APP_SETUP.md` for details

3. **Local Mode**: Files are accessed directly on filesystem
   - Uses current user permissions
   - No Docker isolation
   - Suitable for development only

---

## 📞 **Support & Troubleshooting**

If you still encounter issues:

1. **Check all logs:**
   ```bash
   tail -100 /tmp/openswe-backend.log
   tail -100 /tmp/openswe-frontend.log
   ```

2. **Verify LM Studio:**
   ```bash
   curl http://localhost:1234/v1/models
   ```

3. **Check ports:**
   ```bash
   ss -tulpn | grep -E "2024|3000|3001|3002|3003|3004"
   ```

4. **Full restart:**
   ```bash
   killall -9 node
   sleep 3
   ./start-openswe.sh
   ```

5. **Check browser localStorage:**
   - Open DevTools → Application → Local Storage
   - Find `open-swe-config-storage`
   - Verify model configurations

---

## ✅ **Summary**

**Problem**: Backend failing with HTTP 500 due to missing `SECRETS_ENCRYPTION_KEY` and multiple conflicting process instances.

**Solution**: Created `start-openswe.sh` script that:
1. Cleans up all processes
2. Builds packages
3. Generates encryption key
4. Starts backend with all required env vars
5. Starts frontend
6. Verifies everything is running

**Result**: Clean, reliable startup process that works every time.

**Status**: ✅ **FIXED AND TESTED**

---

*Last Updated: 2025-10-20*
*Script Location: `/home/precision7780/PycharmProjects/open-swe/start-openswe.sh`*

