# GitHub App Callback URL Setup Guide

## 🚨 **Critical Issue: Callback URL Not Whitelisted**

### **Error You're Seeing:**
```
Be careful!
The redirect_uri is not associated with this application.
```

### **Root Cause:**
Your GitHub App doesn't have all required callback URLs whitelisted.

---

## ✅ **Solution: Add ALL Callback URLs to GitHub App**

### **Step 1: Go to GitHub App Settings**

1. Open: https://github.com/settings/apps
2. Click on your app: **`open-swe-sw`**
3. Scroll to **"Callback URL"** section

### **Step 2: Add BOTH Callback URLs**

You need to add **BOTH** of these URLs (GitHub Apps support multiple callback URLs):

```
http://localhost:3001/api/auth/github/callback
http://192.168.218.132:3001/api/auth/github/callback
```

**Why both?**
- `localhost` - When you access from: `http://localhost:3001`
- `192.168.218.132` - When you access from: `http://192.168.218.132:3001`

The app automatically detects which one to use based on how you access it!

### **Step 3: Save Changes**

Click **"Save changes"** at the bottom of the page.

---

## 🎯 **Current Status Check**

### **What Redirect URI is Currently Being Used:**

Check your terminal logs (Terminal 2) - you should see:
```
[GitHub OAuth] Login initiated with redirect URI: http://localhost:3001/api/auth/github/callback
```

This tells you exactly which URL needs to be in GitHub App settings!

---

## 📸 **Visual Guide:**

### **Where to Find Callback URL Setting:**

1. **GitHub App Settings Page** (`https://github.com/settings/apps/YOUR_APP`)
2. Look for **"Identifying and authorizing users"** section
3. Find **"Callback URL"** field

### **What to Add:**

```
┌─────────────────────────────────────────────────────────┐
│ Callback URL                                            │
├─────────────────────────────────────────────────────────┤
│ http://localhost:3001/api/auth/github/callback          │ ← Add this
│                                                          │
│ http://192.168.218.132:3001/api/auth/github/callback    │ ← Add this
└─────────────────────────────────────────────────────────┘
```

**Note**: GitHub interface might show one URL at a time - that's okay! Just add both URLs, separated by newlines or using the "Add" button if available.

---

## 🔍 **Troubleshooting**

### **Still Getting Error After Adding URLs?**

1. **Check Terminal Logs**:
   ```bash
   tail -f /tmp/openswe-web-fixed.log | grep "GitHub OAuth"
   ```

2. **Verify Redirect URI**:
   - The log will show: `[GitHub OAuth] Login initiated with redirect URI: <URL>`
   - Make sure this EXACT URL is in GitHub App settings

3. **Common Mistakes**:
   - ❌ Added `http://localhost:3000` (wrong port)
   - ❌ Added `https://localhost:3001` (wrong protocol)
   - ❌ Only added network IP (missing localhost)
   - ✅ Add exactly: `http://localhost:3001/api/auth/github/callback`

4. **Clear Browser Cache**:
   - Hard refresh: `Ctrl+Shift+R` (Linux/Windows) or `Cmd+Shift+R` (Mac)

---

## 🚀 **After Adding Callback URLs**

### **Test from localhost:**
1. Open: `http://localhost:3001`
2. Click "Connect GitHub"
3. Should redirect to GitHub and back successfully ✅

### **Test from network:**
1. Open: `http://192.168.218.132:3001`
2. Click "Connect GitHub"
3. Should redirect to GitHub and back successfully ✅

---

## 📝 **For Production Deployment**

When deploying to production, add your production callback URL:

```
https://yourdomain.com/api/auth/github/callback
```

The app will automatically use the correct URL based on the domain!

---

## ❓ **FAQ**

### **Q: Why can't I just use one callback URL?**
A: Because the OAuth flow requires the callback URL to **exactly match** where the user is accessing the app from. If they access from `localhost`, the callback must be `localhost`. If they access from `192.168.x.x`, the callback must be that IP.

### **Q: Will this work with any IP address?**
A: You need to whitelist each IP/domain you'll use. For development, add both localhost and your network IP. For dynamic IPs, consider using a domain name instead.

### **Q: Do I need to restart the server after updating GitHub App?**
A: No! GitHub App settings changes are immediate. Just try clicking "Connect GitHub" again.

---

## 🎯 **Quick Checklist**

Before clicking "Connect GitHub":

- [ ] Added `http://localhost:3001/api/auth/github/callback` to GitHub App
- [ ] Added `http://192.168.218.132:3001/api/auth/github/callback` to GitHub App  
- [ ] Clicked "Save changes" in GitHub App settings
- [ ] Web server is running on port 3001
- [ ] Terminal logs show the correct redirect URI

---

**Status**: ⏳ Waiting for you to add callback URLs to GitHub App settings

Once done, refresh your browser and try "Connect GitHub" again! 🚀

