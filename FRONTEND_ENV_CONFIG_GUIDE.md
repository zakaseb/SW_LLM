# Frontend Environment Configuration Guide

## 🚨 Critical Configuration for Web App

This guide provides the correct environment variable configuration for the Open-SWE web frontend.

---

## ✅ Required Changes to `apps/web/.env`

### 1. API URL Configuration

**❌ INCORRECT (causes blank page & JSON errors):**
```bash
NEXT_PUBLIC_API_URL="http://localhost:3000/api"
NEXT_PUBLIC_API_URL="http://127.0.0.1:2024"
```

**✅ CORRECT:**
```bash
NEXT_PUBLIC_API_URL="/api"
```

**Why:**
- Relative path works from any host (localhost, network IP, domain)
- Routes requests through Next.js proxy (handles auth & encryption)
- Prevents direct LangGraph API access (which lacks authentication)

### 2. GitHub OAuth Redirect URI

**❌ INCORRECT (wrong port):**
```bash
GITHUB_APP_REDIRECT_URI="http://localhost:3000/api/auth/github/callback"
```

**✅ CORRECT (for default dev server on port 3001):**
```bash
GITHUB_APP_REDIRECT_URI="http://localhost:3001/api/auth/github/callback"
```

**Note:** If running on a different port, update accordingly.

---

## 📋 Complete `.env` Template for `apps/web/`

```bash
# ------------------Github App Secrets-----------------
# GitHub app client secrets. Used for the GitHub OAuth login flow.
NEXT_PUBLIC_GITHUB_APP_CLIENT_ID="your-client-id-here"
GITHUB_APP_CLIENT_SECRET="your-client-secret-here"

# OAuth callback URL - MUST match GitHub App settings
# Update port to match your dev server (default: 3001)
GITHUB_APP_REDIRECT_URI="http://localhost:3001/api/auth/github/callback"

GITHUB_APP_NAME="your-github-app-name" # Must match your GitHub app name (no spaces)
GITHUB_APP_ID="your-app-id"

# GitHub App Private Key (multi-line)
GITHUB_APP_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
...your private key here...
-----END RSA PRIVATE KEY-----
"

# ------------------------Other------------------------
# Frontend API URL - Use relative path for compatibility
# CRITICAL: Must be "/api" for proper proxy routing
NEXT_PUBLIC_API_URL="/api"

# LangGraph API URL - Used by backend proxy only
LANGGRAPH_API_URL="http://localhost:2024"

# Encryption key for secrets (32-byte hex)
# Generate with: openssl rand -hex 32
SECRETS_ENCRYPTION_KEY="your-32-byte-hex-key-here"
```

---

## 🔧 Setup Instructions

### 1. Copy and Configure

```bash
# Copy this configuration to apps/web/.env
cd apps/web
# Edit .env file with your values
```

### 2. Generate Encryption Key

```bash
openssl rand -hex 32
# Copy the output to SECRETS_ENCRYPTION_KEY
```

### 3. Verify Configuration

```bash
# Check required variables are set
grep -E "(NEXT_PUBLIC_API_URL|GITHUB_APP_REDIRECT_URI)" apps/web/.env
```

Expected output:
```
NEXT_PUBLIC_API_URL="/api"
GITHUB_APP_REDIRECT_URI="http://localhost:3001/api/auth/github/callback"
```

### 4. Start Web Server

```bash
cd apps/web
PORT=3001 yarn dev
```

---

## 🌐 Network Access Configuration

### For Local Network Access (e.g., 192.168.x.x)

The frontend will work from network IPs when `NEXT_PUBLIC_API_URL="/api"` (relative path).

**GitHub OAuth Setup:**
1. Go to your GitHub App settings
2. Add additional callback URL: `http://192.168.x.x:3001/api/auth/github/callback`
3. Or use a proper domain for production

---

## 🐛 Troubleshooting

### Issue: Blank page with "JSON.parse" error

**Cause:** `NEXT_PUBLIC_API_URL` is not set to `"/api"`

**Fix:**
```bash
# Update apps/web/.env
NEXT_PUBLIC_API_URL="/api"

# Restart server
cd apps/web
PORT=3001 yarn dev
```

### Issue: GitHub sign-in hangs/fails

**Cause:** `GITHUB_APP_REDIRECT_URI` doesn't match server port or GitHub App settings

**Fix:**
1. Update `.env`:
   ```bash
   GITHUB_APP_REDIRECT_URI="http://localhost:3001/api/auth/github/callback"
   ```
2. Update GitHub App settings to match
3. Restart server

### Issue: Network access doesn't work

**Cause:** Using absolute URL like `http://localhost:3001/api` instead of relative

**Fix:**
```bash
NEXT_PUBLIC_API_URL="/api"  # Use relative path
```

---

## 🔐 Security Notes

### Why Use the Next.js Proxy?

The proxy (`/apps/web/src/app/api/[..._path]/route.ts`) is essential for:

1. **GitHub Token Injection**: Adds tokens from HTTP-only cookies
2. **API Key Encryption**: Encrypts user API keys before backend transmission
3. **CORS Management**: Handles cross-origin requests properly
4. **Request Validation**: Validates requests before forwarding
5. **Security Headers**: Injects required authentication headers

**⚠️ Never bypass the proxy by pointing directly to LangGraph API**

---

## 📦 Production Deployment

### Environment Variables for Production

```bash
# Use relative path (works with any domain)
NEXT_PUBLIC_API_URL="/api"

# Use production domain for OAuth
GITHUB_APP_REDIRECT_URI="https://yourdomain.com/api/auth/github/callback"

# Keep backend proxy target as localhost (server-side only)
LANGGRAPH_API_URL="http://localhost:2024"

# Use strong encryption key
SECRETS_ENCRYPTION_KEY="<generate-new-key-for-production>"
```

### GitHub App Configuration

- **Development:** `http://localhost:3001/api/auth/github/callback`
- **Production:** `https://yourdomain.com/api/auth/github/callback`

GitHub Apps support multiple callback URLs - configure both!

---

## ✅ Verification Checklist

Before running the app, verify:

- [ ] `NEXT_PUBLIC_API_URL="/api"` (relative path)
- [ ] `GITHUB_APP_REDIRECT_URI` matches your port/domain
- [ ] `GITHUB_APP_REDIRECT_URI` is configured in GitHub App settings
- [ ] `SECRETS_ENCRYPTION_KEY` is set (32-byte hex)
- [ ] All GitHub App credentials are configured
- [ ] `LANGGRAPH_API_URL="http://localhost:2024"` (backend only)

---

## 📚 Related Documentation

- [Main Frontend Fix Documentation](./FRONTEND_FIX_DOCUMENTATION.md)
- [Setup Guide](./apps/docs/setup/development.mdx)
- [GitHub App Authentication](./apps/docs/setup/authentication.mdx)

---

**Last Updated:** October 14, 2025  
**Status:** Production Ready ✅

