# ⚠️ ACTION REQUIRED: Fix GitHub OAuth

## 🚨 Current Issue

**Error**: "The redirect_uri is not associated with this application"

**Cause**: Your GitHub App doesn't have the required callback URLs whitelisted.

---

## ✅ **SOLUTION (5 minutes)**

### **Step 1: Go to GitHub App Settings**

Click this link: https://github.com/settings/apps/open-swe-sw

(Or go to: Settings → Developer settings → GitHub Apps → Your App)

### **Step 2: Find "Callback URL" Section**

Scroll down to **"Identifying and authorizing users"**

Look for **"Callback URL"** field

### **Step 3: Add BOTH These URLs**

```
http://localhost:3001/api/auth/github/callback
http://192.168.218.132:3001/api/auth/github/callback
```

**Important**: Add BOTH URLs!
- First one: For when you access from `http://localhost:3001`
- Second one: For when you access from `http://192.168.218.132:3001`

### **Step 4: Save Changes**

Click **"Save changes"** at the bottom of the GitHub App settings page.

### **Step 5: Test**

1. Refresh your browser at `http://localhost:3001`
2. Click "Connect GitHub" button
3. Should redirect to GitHub and back successfully! ✅

---

## 🔍 **How to Verify It's Working**

### **Check Server Logs** (Terminal 2):

When you click "Connect GitHub", you should see:

```
[GitHub OAuth] Login initiated with redirect URI: http://localhost:3001/api/auth/github/callback
[GitHub OAuth] IMPORTANT: This URL must be whitelisted in your GitHub App settings
[GitHub OAuth] Go to: https://github.com/settings/apps → Your App → Callback URL
```

This tells you exactly which URL GitHub is expecting!

### **If Still Having Issues**:

1. Make sure the URL shown in logs **EXACTLY** matches what you added to GitHub App
2. Check for typos (common: wrong port, wrong protocol)
3. Make sure you clicked "Save changes" in GitHub App settings
4. Try a hard refresh in browser: `Ctrl+Shift+R`

---

## 📚 **Documentation**

For detailed setup instructions, see: [`GITHUB_APP_SETUP.md`](./GITHUB_APP_SETUP.md)

---

## 🎯 **Why This Happens**

The application now uses **dynamic redirect URIs** that automatically adapt to how you access it:

- Access from `localhost` → Uses `localhost` callback
- Access from `192.168.x.x` → Uses that IP's callback
- Access from `yourdomain.com` → Uses that domain's callback

This makes deployment easier, but GitHub needs to have each URL whitelisted for security!

---

## ✨ **After This Works**

Once OAuth is working, the application is **fully functional**:

- ✅ Connect to GitHub
- ✅ Select repositories
- ✅ Choose branches  
- ✅ Submit tasks to LM Studio-powered agents
- ✅ Works from localhost AND network IPs

---

**Current Status**: ⏳ **Waiting for you to add callback URLs to GitHub App**

**Time Required**: ~5 minutes

**Next Step**: Add both URLs to GitHub App settings, then test!

