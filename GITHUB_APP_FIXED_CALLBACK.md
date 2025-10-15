# GitHub App Configuration (Fixed Callback URL)

## 🚨 Important: GitHub Apps vs OAuth Apps

**GitHub Apps** support only **ONE** callback URL (unlike OAuth Apps which support multiple).

This means you need to choose ONE primary access method for your development environment.

---

## ✅ **Solution: Configure for Your Primary Access Method**

### **Option 1: Access Primarily from localhost**

**Step 1:** Set in `apps/web/.env`:
```bash
GITHUB_APP_REDIRECT_URI="http://localhost:3001/api/auth/github/callback"
```

**Step 2:** Set in GitHub App settings:
- Go to: https://github.com/settings/apps/open-swe-sw
- Find "Callback URL" field
- Set to: `http://localhost:3001/api/auth/github/callback`
- Click "Save changes"

**Result:**
- ✅ Works from `http://localhost:3001`
- ❌ Won't work from `http://192.168.218.132:3001` (different URL)

---

### **Option 2: Access Primarily from Network IP**

**Step 1:** Set in `apps/web/.env`:
```bash
GITHUB_APP_REDIRECT_URI="http://192.168.218.132:3001/api/auth/github/callback"
```

**Step 2:** Set in GitHub App settings:
- Go to: https://github.com/settings/apps/open-swe-sw
- Find "Callback URL" field
- Set to: `http://192.168.218.132:3001/api/auth/github/callback`
- Click "Save changes"

**Result:**
- ✅ Works from `http://192.168.218.132:3001`
- ✅ Works from other devices on network accessing `http://192.168.218.132:3001`
- ❌ Won't work from `http://localhost:3001` (different URL)

---

## 🔄 **Recommended: Use Network IP for Flexibility**

**Why?** Using the network IP (`192.168.218.132:3001`) allows:
- ✅ Access from the same machine (just use the IP instead of localhost)
- ✅ Access from other devices on your network
- ✅ More flexible for testing

**Configuration:**

1. **Update `.env`**:
   ```bash
   cd /home/precision7780/PycharmProjects/open-swe
   nano apps/web/.env
   
   # Change this line:
   GITHUB_APP_REDIRECT_URI="http://192.168.218.132:3001/api/auth/github/callback"
   ```

2. **Update GitHub App**:
   - URL: https://github.com/settings/apps/open-swe-sw
   - Set Callback URL to: `http://192.168.218.132:3001/api/auth/github/callback`
   - Save changes

3. **Restart Web Server**:
   ```bash
   # Kill old server
   cd /home/precision7780/PycharmProjects/open-swe
   kill -9 $(ps aux | grep "[n]ext.*dev" | awk '{print $2}')
   
   # Start new server
   cd apps/web
   PORT=3001 yarn dev
   ```

4. **Access Application**:
   - Open browser to: `http://192.168.218.132:3001`
   - Click "Connect GitHub"
   - Should work! ✅

---

## 🎯 **Current Configuration Check**

Run this to see your current setting:
```bash
grep GITHUB_APP_REDIRECT_URI apps/web/.env
```

Your redirect URI should **EXACTLY** match what's in GitHub App settings!

---

## 🐛 **Troubleshooting**

### **Error: "redirect_uri is not associated with this application"**

**Cause**: Mismatch between:
- What's in `apps/web/.env` (GITHUB_APP_REDIRECT_URI)
- What's in GitHub App settings (Callback URL)
- What URL you're accessing the app from

**Solution**:
1. Decide: localhost OR network IP?
2. Set BOTH `.env` AND GitHub App to the SAME URL
3. Access app from that URL

### **Example of Correct Setup:**

**Configuration**:
```bash
# In apps/web/.env
GITHUB_APP_REDIRECT_URI="http://192.168.218.132:3001/api/auth/github/callback"
```

**GitHub App Settings**:
```
Callback URL: http://192.168.218.132:3001/api/auth/github/callback
```

**Access From**:
```
Browser: http://192.168.218.132:3001
```

**Result**: ✅ Works!

---

## 📝 **For Production**

When deploying to production:

1. **Update `.env`**:
   ```bash
   GITHUB_APP_REDIRECT_URI="https://yourdomain.com/api/auth/github/callback"
   ```

2. **Update GitHub App**:
   - Set Callback URL to: `https://yourdomain.com/api/auth/github/callback`

3. **Deploy**

---

## ⚠️ **What Changed From Previous Approach**

**Previous (Dynamic)**: Attempted to automatically detect and use the correct callback URL
- ❌ Doesn't work with GitHub Apps (only OAuth Apps)
- ❌ GitHub Apps require exact URL match

**Current (Fixed)**: Uses one configured callback URL from `.env`
- ✅ Works with GitHub Apps
- ✅ Matches GitHub's security requirements
- ⚠️ Must choose one primary access method

---

## 🔍 **Verification**

After configuration, check Terminal logs when clicking "Connect GitHub":

```
[GitHub OAuth] Login initiated with redirect URI: http://192.168.218.132:3001/api/auth/github/callback
[GitHub OAuth] Make sure this EXACT URL is set in your GitHub App settings
```

The URL shown must **EXACTLY** match:
1. Your `.env` file setting
2. Your GitHub App Callback URL setting
3. How you're accessing the app in browser

---

**Status**: ✅ **Fixed to work with GitHub Apps**

**Next Step**: Choose your primary access method and configure accordingly!



