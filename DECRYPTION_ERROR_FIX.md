# 🔴 CRITICAL: Decryption Error Fix

## ❌ **The Error**

**Backend logs:**
```
Error: Failed to decrypt secret: Unsupported state or unable to authenticate data
at decryptSecret (file:///home/precision7780/PycharmProjects/open-swe/packages/shared/dist/crypto.js:99:15)
at Object.authenticate (/home/precision7780/PycharmProjects/open-swe/apps/open-swe/src/security/auth.ts:147:9)
```

**Frontend console:**
```
Missing environment variables for regenerating installation token.
StreamError
```

---

## 🔍 **Root Cause**

### **Problem 1: Old Encrypted Data**

When you manually changed `SECRETS_ENCRYPTION_KEY`, your browser still had cookies/tokens encrypted with the **OLD key**.

**Timeline:**
1. ✅ You logged in with GitHub → Frontend encrypted token with OLD key
2. ✅ Token stored in browser cookies
3. ✅ You changed encryption key manually
4. ❌ Browser sends old encrypted token → Backend tries to decrypt with NEW key
5. ❌ Decryption fails → HTTP 500 error

### **Problem 2: Port Mismatch**

- **GitHub App Callback URL**: `http://localhost:3000/api/auth/github/callback`
- **App Currently Running On**: Port 3005
- **Result**: OAuth won't work from port 3005

---

## ✅ **Complete Solution**

### **Step 1: Clear Browser Data**

You MUST clear all encrypted data from your browser:

#### **Option A: Clear Specific Storage (Recommended)**
1. Open DevTools (F12)
2. Go to **Application** tab
3. **Clear these items:**
   - **Cookies** (all from `localhost`)
   - **Local Storage** → `open-swe-config-storage`
   - **Session Storage** (all items)
4. Close DevTools
5. **Hard Refresh**: `Ctrl+Shift+R` (or `Cmd+Shift+R` on Mac)

#### **Option B: Clear All Site Data**
1. Open DevTools (F12)
2. Application → **Clear storage**
3. Check ALL boxes
4. Click "Clear site data"
5. Hard refresh the page

### **Step 2: Fix Port Mismatch**

Since the GitHub App callback URL is set to port 3000, you have TWO options:

#### **Option A: Run on Port 3000 (Easier)**

Kill all processes and start fresh - Next.js will use port 3000 if available:

```bash
# Kill everything
killall -9 node
sleep 3

# Start backend
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev &

# Wait 15 seconds
sleep 15

# Start frontend (will use port 3000 if available)
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev
```

#### **Option B: Add Port 3005 to GitHub App (More Work)**

1. Go to GitHub App settings
2. Add additional callback URL: `http://localhost:3005/api/auth/github/callback`
3. Save
4. Continue using port 3005

**I recommend Option A** - it's simpler and the callback is already configured for 3000.

### **Step 3: Re-authenticate**

After clearing browser data and ensuring correct port:

1. **Open**: `http://localhost:3000` (or your current port)
2. **Sign in with GitHub** - This will encrypt tokens with the NEW key
3. **Complete OAuth flow**
4. **Configure models**: Settings → Configuration → Set all 5 to LM Studio
5. **Test**: Submit a prompt

---

## 🧪 **Verification Steps**

### **1. Check Backend Logs**

```bash
# Find your backend process
ps aux | grep "yarn dev" | grep open-swe

# Check logs (no more decryption errors)
# Should NOT see "Failed to decrypt secret"
```

### **2. Check Browser Console**

- Open DevTools → Console
- Should NOT see "Missing environment variables for regenerating installation token"
- Should NOT see "Failed to decrypt secret"

### **3. Test End-to-End**

1. Sign in with GitHub ✅
2. Select repository ✅
3. Select branch ✅
4. Submit prompt ✅
5. Task starts without errors ✅

---

## 📋 **Why This Happens**

### **The Encryption Flow:**

```
OLD SESSION:
Frontend encrypts with KEY_A → Stores in browser → Backend decrypts with KEY_A ✅

AFTER KEY CHANGE:
Frontend tries to use old data encrypted with KEY_A → Backend decrypts with KEY_B ❌
```

**Solution**: Clear old encrypted data and re-authenticate with new key.

---

## 🚨 **Port Mismatch Explained**

### **How GitHub OAuth Works:**

1. User clicks "Sign in with GitHub"
2. Frontend redirects to: `https://github.com/login/oauth/authorize?redirect_uri=http://localhost:3000/api/auth/github/callback`
3. User authorizes
4. GitHub redirects back to: `http://localhost:3000/api/auth/github/callback`
5. Frontend receives token

### **The Problem:**

- GitHub App is configured for port **3000**
- Your app is running on port **3005**
- GitHub will redirect to **3000** (configured)
- But your app is on **3005** (running)
- **Result**: OAuth callback goes to wrong port → fails

### **The Solution:**

**Either**:
- Run on port 3000 (matches configured callback)
- **Or** add port 3005 to GitHub App callback URLs

---

## 🔧 **Complete Restart Procedure**

Here's the full procedure to fix everything:

```bash
# 1. Kill all processes
killall -9 node
sleep 3

# 2. Verify encryption keys match (should already be done)
BACKEND_KEY=$(grep SECRETS_ENCRYPTION_KEY /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env | cut -d'=' -f2 | tr -d '"')
FRONTEND_KEY=$(grep SECRETS_ENCRYPTION_KEY /home/precision7780/PycharmProjects/open-swe/apps/web/.env | cut -d'=' -f2 | tr -d '"')

if [ "$BACKEND_KEY" = "$FRONTEND_KEY" ]; then
  echo "✅ Keys match"
else
  echo "❌ Keys don't match - FIX THIS FIRST!"
  exit 1
fi

# 3. Start backend
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev > /tmp/backend-clean-start.log 2>&1 &
echo "Backend starting..."

# 4. Wait for backend
sleep 15

# 5. Start frontend (will use port 3000 if available)
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev > /tmp/frontend-clean-start.log 2>&1 &
echo "Frontend starting..."

# 6. Wait for frontend
sleep 15

# 7. Check status
echo ""
echo "=== STATUS ==="
echo "Backend:"
ss -tulpn | grep 2024
echo ""
echo "Frontend:"
ss -tulpn | grep next-server | head -1
echo ""
echo "Frontend URL (check the log for exact port):"
tail -10 /tmp/frontend-clean-start.log | grep "Local:"
```

---

## ✅ **Post-Restart Checklist**

After restarting services:

1. **Clear Browser Data** (CRITICAL!)
   - [ ] Cookies cleared
   - [ ] Local Storage cleared
   - [ ] Session Storage cleared
   - [ ] Hard refresh done

2. **Verify Port**
   - [ ] Frontend is on port 3000 (or callback URL updated for other port)

3. **Re-authenticate**
   - [ ] Sign in with GitHub
   - [ ] OAuth completes successfully
   - [ ] Can see repositories

4. **Configure Models**
   - [ ] Settings → Configuration
   - [ ] All 5 models set to `LM Studio - openai/gpt-oss-20b`
   - [ ] Configuration saved

5. **Test**
   - [ ] Select repository
   - [ ] Select branch
   - [ ] Submit prompt
   - [ ] Task starts without errors

---

## 📊 **Current Encryption Key**

**Both .env files now have:**
```
f6d04078495db516f0022d2ab4dc33029575fb96e3419c85fa9eb238a3eb3dad
```

✅ **Verified: Keys match in both files**

---

## 🎯 **Summary**

**Problem**: Decryption errors because browser has tokens encrypted with old key  
**Solution**: Clear browser data and re-authenticate with new key  
**Port Issue**: GitHub callback set to 3000, app running on 3005  
**Solution**: Run on port 3000 or add 3005 to GitHub App settings  

**Status**: Ready to fix - follow the steps above

---

## 💡 **Important Notes**

### **When to Clear Browser Data:**

You MUST clear browser data whenever you:
- Change `SECRETS_ENCRYPTION_KEY`
- Change ports
- Get "Failed to decrypt secret" errors
- Get "Missing environment variables" errors

### **Why Port Matters:**

GitHub OAuth requires exact URL matching. If callback is `localhost:3000` but app runs on `localhost:3005`, OAuth will fail or tokens will go to wrong port.

### **Session Persistence:**

After clearing and re-authenticating:
- ✅ New tokens encrypted with NEW key
- ✅ Backend can decrypt successfully
- ✅ No more errors

---

## 🚀 **Quick Fix (TL;DR)**

1. **Clear browser storage** (DevTools → Application → Clear all)
2. **Kill all Node processes**: `killall -9 node`
3. **Start backend**: `cd apps/open-swe && yarn dev`
4. **Start frontend**: `cd apps/web && yarn dev` (should use port 3000)
5. **Hard refresh browser**: `Ctrl+Shift+R`
6. **Sign in with GitHub** (re-authenticates with new key)
7. **Test**: Submit a prompt

---

**This will resolve both the decryption error and the port mismatch issue.** ✅

