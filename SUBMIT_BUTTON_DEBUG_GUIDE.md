# Submit Button Debugging Guide

## Issue
The submit button on the OpenSWE web interface does nothing when clicked.

## What I've Done

### 1. Added Comprehensive Logging
I've added detailed logging to help diagnose the issue:

#### In `apps/web/src/components/v2/terminal-input.tsx`:
- Logs when submit is clicked
- Logs the selected repository
- Logs the user information
- Logs the default configuration
- Logs whether the user is allowed
- Logs whether API keys are set
- Logs any errors that occur during submission

####In `apps/web/src/lib/api-keys.ts`:
- Logs the entire configuration object
- Logs which model names are configured
- Logs which providers are enabled
- Logs which providers require API keys
- Logs the decision logic for LM Studio support

### 2. Improved Error Handling
The submit button now shows error toast messages for all failures, not just API key errors.

## Testing Instructions

### Step 1: Access the Frontend
The Next.js dev server is now running on **port 3000** (not 3001):
- **Localhost**: http://localhost:3000
- **Network**: http://192.168.218.132:3000

### Step 2: Open Browser Console
1. Open the web page in your browser
2. Open Developer Tools (F12 or right-click → Inspect)
3. Go to the Console tab
4. Keep it open during testing

### Step 3: Sign In and Test
1. Click "Sign in with GitHub"
2. Complete the OAuth flow
3. Select a repository from the dropdown
4. Select a branch
5. Type a message in the input box (e.g., "Add a README file")
6. **Open the console (if not already open)**
7. Click the Submit button (or press Cmd/Ctrl+Enter)

### Step 4: Check the Console Logs
Look for logs starting with:
- `[Submit]` - Shows the submission flow
- `[hasApiKeySet]` - Shows the API key configuration check

**Copy ALL the console output** and share it with me.

## What to Look For

### Scenario 1: No Console Logs
If you see NO logs starting with `[Submit]` when you click the button:
- The button click handler isn't firing
- This could be a React state issue or the button is disabled

### Scenario 2: Logs Show "Blocked: No API keys configured"
```
[Submit] Blocked: No API keys configured
```
This means:
- You haven't configured LM Studio models in the settings
- OR the configuration isn't being saved properly

**Solution**: Go to Settings → Configuration and set your models to use LM Studio.

### Scenario 3: Logs Show Error
```
[Submit Error] <some error message>
```
The error message will tell us exactly what's failing.

### Scenario 4: Logs Show Success but Page Doesn't Navigate
If logs show the submission started but you don't navigate to `/chat/{threadId}`:
- There might be an issue with the LangGraph server connection
- Check the network tab for failed API requests

## Common Issues and Solutions

### Issue: "Please select a repository first"
**Cause**: No repository selected
**Solution**: Make sure you've selected both a repository AND a branch

### Issue: "User not found. Please sign in first"
**Cause**: OAuth session expired or not authenticated
**Solution**: Sign out and sign back in with GitHub

### Issue: "Missing API keys"
**Cause**: No LM Studio models configured OR other providers configured without API keys
**Solution**: 
1. Go to Settings (gear icon)
2. Go to Configuration tab
3. For each model setting (e.g., `plannerModelName`, `programmerModelName`):
   - Change from default (anthropic) to an LM Studio model
   - Format: `lmstudio:model-identifier`
   - Example: `lmstudio:llama-3.1-8b-instruct`

### Issue: "Open SWE requires issues to be enabled"
**Cause**: The selected repository has GitHub Issues disabled
**Solution**: 
1. Go to the repository on GitHub
2. Settings → General → Features
3. Check "Issues"

## LM Studio Configuration

For the submit button to work with LM Studio, you need to configure ALL model settings:

1. Go to http://localhost:3000/settings?tab=configuration
2. Configure these settings (look for fields ending in "ModelName"):
   - `plannerModelName`: `lmstudio:your-model-name`
   - `programmerModelName`: `lmstudio:your-model-name`
   - `reviewerModelName`: `lmstudio:your-model-name`
   - (Any other modelName fields)

3. You can use the same model for all tasks or different models:
   ```
   lmstudio:llama-3.1-8b-instruct
   lmstudio:codellama-13b
   lmstudio:mistral-7b-instruct
   ```

4. Make sure LM Studio is running and serving on `http://localhost:1234`

## Server Configuration

Make sure your `.env` file in `apps/web` has:
```bash
NEXT_PUBLIC_API_URL="/api"
NEXT_PUBLIC_MODE=local
LANGGRAPH_API_URL="http://localhost:2024"
```

## Next Steps

1. Follow the testing instructions above
2. Copy ALL console logs (both `[Submit]` and `[hasApiKeySet]` logs)
3. Share them with me
4. I'll identify the exact issue and fix it

## Current Server Status

✅ Next.js dev server running on port 3000
- Local: http://localhost:3000
- Network: http://192.168.218.132:3000

📝 Logs being written to: `/tmp/openswe-web-debug.log`

## Port Configuration Note

The server is currently running on port **3000** (not 3001). This is because:
- The `PORT` environment variable in the command wasn't being respected
- Next.js defaults to port 3000

If you need it on port 3001, update your GitHub App callback URL to:
```
http://localhost:3000/api/auth/github/callback
```

Or we can force it to run on 3001 by modifying the `package.json` dev script.

