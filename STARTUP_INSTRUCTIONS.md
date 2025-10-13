# Open SWE - Local Setup with LM Studio

## Current Configuration Status ✓

- ✅ LM Studio running on port 1234
- ✅ LangGraph server running on port 2024  
- ✅ Port 3000 now available (process killed)
- ✅ GitHub App credentials configured
- ✅ Model manager updated for local LLM mode

## Steps to Start the Application

### 1. Clean Up Processes (IMPORTANT)

```bash
# Kill duplicate LangGraph server instances
kill 1187630 1187641 1342697 1367222 1367244 2>/dev/null

# Verify port 2024 is free
lsof -ti:2024 || echo "Port 2024 is free"
```

### 2. Start LangGraph Server (Terminal 1)

```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev
```

Wait for: `✓ Ready on http://localhost:2024`

### 3. Start Web App (Terminal 2) 

```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev
```

Should now show: `http://localhost:3000` (not 3001)

### 4. Access the Application

1. Open browser: http://localhost:3000
2. You'll be prompted to authenticate with GitHub
3. Click "Sign in with GitHub" - should now work correctly
4. After OAuth completes, select your repository and branch
5. Choose model: **"LM Studio (Local)"** from the settings
6. Submit your task - it will use your local LM Studio model

## Troubleshooting

### "Error loading branches"
- Ensure you've completed GitHub OAuth login
- Check that `GITHUB_INSTALLATION_ID_COOKIE` is set (happens after first login)
- Verify GitHub App has access to the repository

### "Submit button does nothing"
- Verify LangGraph server is running on port 2024
- Check browser console for errors (F12)
- Ensure `NEXT_PUBLIC_API_URL` in web/.env points to correct port

### Terminal 2 Errors (LangGraph Server)
If you see errors in the LangGraph terminal:
- Model initialization errors → Check LM Studio is running and serving on port 1234
- API key errors → These should be ignored in local mode (my fix handles this)
- Sandbox/Daytona errors → These are for cloud sandboxes, can be ignored for local testing

## Environment Files Summary

**apps/web/.env:**
- GitHub OAuth configured ✓
- Redirect URI: http://localhost:3000/api/auth/github/callback ✓
- API URL: http://127.0.0.1:2024 ✓

**apps/open-swe/.env:**
- OPENAI_API_BASE: http://localhost:1234/v1 ✓
- OPENAI_API_KEY: lmstudio-local ✓
- Local mode enabled ✓

## What Was Fixed

1. **Model Manager** (`apps/open-swe/src/utils/llms/model-manager.ts`)
   - Now skips API key requirements when `OPENAI_API_BASE` is set
   - Disables cloud fallbacks in local mode
   - Properly handles `anythingllm` and LM Studio providers

2. **Port Management**
   - Killed process occupying port 3000
   - Web app can now run on correct port for OAuth

3. **GitHub Integration**
   - Proxy routes verified working
   - OAuth flow will work once app is on port 3000

