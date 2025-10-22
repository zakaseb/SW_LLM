# 🔧 LOCAL MODE SANDBOX FIX - Complete Solution

## ❌ **The Problem**

When running OpenSWE locally with LM Studio, the planner task failed with:

```
Error: Failed to create sandbox environment.
DaytonaError: Organization ID is required when using JWT token
```

---

## 🔍 **Root Cause**

The `isLocalMode()` function only checked the UI configuration (`config.configurable["x-local-mode"]`) but **ignored** the environment variable `OPEN_SWE_LOCAL_MODE=true`.

**Result**: Even though the environment variable was set, the system still tried to create a Daytona sandbox, which failed.

---

## ✅ **The Fix**

### **Modified Function: `isLocalMode()`**

**File**: `packages/shared/src/open-swe/local-mode.ts`

**Before**:
```typescript
export function isLocalMode(config?: GraphConfig): boolean {
  if (!config) {
    return isLocalModeFromEnv();
  }
  return (config.configurable as any)?.["x-local-mode"] === "true";
}
```

**After**:
```typescript
export function isLocalMode(config?: GraphConfig): boolean {
  if (!config) {
    return isLocalModeFromEnv();
  }
  // Check config first, then fallback to environment variable
  const configLocalMode = (config.configurable as any)?.["x-local-mode"] === "true";
  return configLocalMode || isLocalModeFromEnv();
}
```

### **What Changed**:
1. **Checks UI config first**: `config.configurable["x-local-mode"]`
2. **Falls back to environment variable**: `process.env.OPEN_SWE_LOCAL_MODE`
3. **Returns true if EITHER is set**

---

## 🎯 **Result**

### **Before the Fix**:
- ❌ Sandbox creation attempted
- ❌ DaytonaError thrown
- ❌ Planner task failed

### **After the Fix**:
- ✅ Local mode detected from environment variable
- ✅ Sandbox creation **skipped**
- ✅ Repository cloning **skipped**
- ✅ Works directly with local filesystem
- ✅ Planner task proceeds successfully

---

## 📝 **Backend Logs (Expected Behavior)**

When local mode is active, you'll see:

```
[InitializeSandbox] Creating sandbox → status: "skipped"
[InitializeSandbox] Cloning repository → status: "skipped"
[InitializeSandbox] Checking out branch → status: "skipped"
[InitializeSandbox] Generating codebase tree → status: "success"
```

**NO MORE**:
```
DaytonaError: Organization ID is required when using JWT token
Failed to create sandbox environment
```

---

## 🔧 **Environment Variables Required**

**Backend**: `apps/open-swe/.env`

```env
# Enable Local Mode
OPEN_SWE_LOCAL_MODE=true

# LM Studio Configuration
LMSTUDIO_BASE_URL=http://localhost:1234/v1
LM_STUDIO_MODEL_NAME=openai/gpt-oss-20b

# GitHub App Credentials
GITHUB_APP_ID=1779334
GITHUB_APP_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
[your private key]
-----END RSA PRIVATE KEY-----"

# Encryption Key (must match frontend)
SECRETS_ENCRYPTION_KEY=[your key]
```

---

## 🚀 **How to Test**

1. **Ensure environment variable is set**:
   ```bash
   grep "OPEN_SWE_LOCAL_MODE" apps/open-swe/.env
   # Should show: OPEN_SWE_LOCAL_MODE=true
   ```

2. **Restart backend**:
   ```bash
   cd apps/open-swe
   yarn dev
   ```

3. **Submit a task**:
   - Open: `http://localhost:3000`
   - Select repository: `zakaseb/temperature_prediction`
   - Select branch: `main`
   - Submit: `"Show me the contents of README.md"`

4. **Check logs**:
   ```bash
   tail -f /tmp/backend-local-mode-fix.log | grep -E "(sandbox|Daytona)"
   ```

   **Expected**: "Creating sandbox" with status "skipped"  
   **NOT**: "DaytonaError" or "Failed to create"

---

## 📚 **Related Fixes**

This fix is part of a series of fixes for local LM Studio operation:

1. **Router Model Fix** (Commit: `1922e68`)
   - Changed router default from Anthropic to LM Studio
   - Prevents "All fallback models exhausted" errors

2. **GitHub App Credentials** (Commit: `c8ca73d`)
   - Added real credentials to backend
   - Fixes "Missing environment variables" errors

3. **Local Mode Sandbox Fix** (Commit: `821d17f`)
   - This fix - enables local mode via environment variable
   - Skips Daytona sandbox creation

---

## 🎉 **Status**

✅ **FIXED AND TESTED**  
✅ **COMMITTED**: `821d17f`  
✅ **BACKEND RUNNING**: Port 2024  
✅ **LOCAL MODE ACTIVE**: No sandbox creation  

---

## 📖 **Technical Details**

### **Call Stack**:
1. `initializeSandbox()` called by planner graph
2. Calls `isLocalMode(config)`
3. Previously: Only checked `config.configurable["x-local-mode"]`
4. Now: Also checks `process.env.OPEN_SWE_LOCAL_MODE`
5. If true: Calls `initializeSandboxLocal()` instead
6. Result: No Daytona client creation, no sandbox errors

### **Local Mode Behavior**:
- **Skips**: Sandbox creation, repo cloning, branch checkout
- **Executes**: Codebase tree generation from local files
- **Uses**: `getLocalWorkingDirectory()` for file operations
- **Returns**: Mock sandbox ID for consistency

---

## 🔗 **References**

- **File**: `packages/shared/src/open-swe/local-mode.ts`
- **Function**: `isLocalMode()`, `initializeSandboxLocal()`
- **Environment Variable**: `OPEN_SWE_LOCAL_MODE`
- **Backend Logs**: `/tmp/backend-local-mode-fix.log`

---

**Last Updated**: October 22, 2025  
**Commit**: `821d17f`  
**Status**: ✅ Operational

