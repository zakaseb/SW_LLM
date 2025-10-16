# 🏠 Enable Local Mode (No Docker/Daytona Required!)

## The Problem

You're getting: **"Failed to create sandbox environment"**

This happens because OpenSWE is trying to create a Daytona sandbox (Docker container), but you don't have Daytona configured.

---

## ✅ Solution: Enable Local Mode

OpenSWE has a **LOCAL MODE** that works directly with your local filesystem - NO Docker required!

### Step 1: Create Backend `.env` File

```bash
cat > /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env << 'EOF'
# Enable Local Mode (works with local filesystem, no Docker/Daytona needed)
OPEN_SWE_LOCAL_MODE=true

# LM Studio API URL
LMSTUDIO_BASE_URL=http://localhost:1234/v1
EOF
```

### Step 2: Restart Backend

```bash
# Kill backend
pkill -9 -f "open-swe.*yarn dev"

# Start backend
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev &
```

Wait for:
```
╦  ┌─┐┌┐┌┌─┐╔═╗┬─┐┌─┐┌─┐┬ ┬
║  ├─┤││││ ┬║ ╦├┬┘├─┤├─┘├─┤
╩═╝┴ ┴┘└┘└─┘╚═╝┴└─┴ ┴┴  ┴ ┴.js
- 🚀 API: http://localhost:2024
```

### Step 3: Test

1. Go to http://localhost:3000
2. Select repo: `zakaseb/temperature_prediction`
3. Submit: "Add a comment to the README"

---

## 📝 How Local Mode Works

### Normal Mode (Sandbox/Daytona)
```
OpenSWE → Creates Docker container → Clones repo → Makes changes → Pushes to GitHub
```

### Local Mode (Direct Filesystem)
```
OpenSWE → Works directly on local files → Makes changes → You can commit manually
```

### Key Differences

| Feature | Normal Mode | Local Mode |
|---------|-------------|------------|
| **Setup** | Needs Daytona/Docker | No setup needed |
| **Isolation** | Fully isolated sandbox | Works on local files |
| **Speed** | Slower (container creation) | Faster (direct access) |
| **GitHub** | Auto-commits & pushes | You control commits |
| **Safety** | Changes in container | Changes on local disk |

---

## 🎯 What This Fixes

### Before (With Sandbox)
```
❌ Failed to create sandbox environment
❌ Planner works, but programmer can't execute
❌ GitHub issues created but empty
```

### After (Local Mode)
```
✅ No sandbox needed
✅ Programmer works directly on files
✅ Changes made to local repository
✅ You can review and commit manually
```

---

## 🔍 Verification

### Check Local Mode is Enabled

**Backend logs should show**:
```
[InitializeSandbox] Local mode enabled
Skipping sandbox creation
Skipping repository cloning
Working directory: /path/to/repo
```

### Check Changes Are Being Made

When you submit a task, OpenSWE will:
1. ✅ Read files from your local repo
2. ✅ Make edits directly to local files
3. ✅ Generate diffs and show them in UI
4. ✅ You can `git status` to see the changes

---

## ⚙️ Advanced Configuration

### Work on Specific Repository

If you want to ALWAYS work on the same local repo:

```bash
# Add to apps/open-swe/.env
OPEN_SWE_LOCAL_PROJECT_PATH=/home/precision7780/repos/my-project
```

### Disable Local Mode (If You Setup Daytona Later)

```bash
# In apps/open-swe/.env, change to:
OPEN_SWE_LOCAL_MODE=false
```

---

## 🚨 Important Notes

### 1. GitHub Integration Still Works

Local mode doesn't disable GitHub integration:
- ✅ You can still connect to GitHub
- ✅ Branch selection works
- ✅ Issues/PRs can be created
- ⚠️ BUT: Auto-commits won't happen (you commit manually)

### 2. Repository Must Exist Locally

For local mode to work:
- Repository must be cloned on your machine
- You must have write permissions
- Git must be initialized

### 3. Manual Commits

After OpenSWE makes changes:
```bash
cd /path/to/your/repo
git status              # See what changed
git add .               # Stage changes
git commit -m "Changes from OpenSWE"
git push                # Push to GitHub
```

---

## 🐛 Troubleshooting

### Issue: Still Getting Sandbox Errors

**Check**:
```bash
# Verify .env file exists
cat /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env

# Should show:
# OPEN_SWE_LOCAL_MODE=true
```

**If not**:
```bash
echo "OPEN_SWE_LOCAL_MODE=true" > /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env
```

**Then restart backend**:
```bash
pkill -9 -f "open-swe.*yarn dev"
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev
```

### Issue: "Permission Denied" When Making Changes

**Solution**: Ensure OpenSWE has write permissions to the repository directory.

```bash
# Check permissions
ls -la /path/to/your/repo

# If needed, fix permissions
chmod -R u+w /path/to/your/repo
```

### Issue: Programmer Still Not Executing

This is a different issue from sandbox creation. Possible causes:

1. **LM Studio Model Limitations**: The model might not be generating proper tool calls
2. **Context Length**: The task might be too complex for the model
3. **Tool Calling Format**: LM Studio might not be handling structured outputs correctly

**Debug**:
1. Check backend logs for tool calling attempts
2. Look for LM Studio API errors
3. Try a simpler task first: "Show me the contents of README.md"

---

## ✅ Quick Verification Steps

After enabling local mode:

- [ ] Created `/home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env`
- [ ] Set `OPEN_SWE_LOCAL_MODE=true`
- [ ] Restarted backend
- [ ] Backend logs show "Local mode enabled" or "Skipping sandbox creation"
- [ ] Submitted test task
- [ ] No more "Failed to create sandbox environment" errors
- [ ] Programmer attempts to make changes (check backend logs)
- [ ] Changes appear in local repository (`git status` shows modifications)

---

## 📊 Expected vs Actual

### ✅ What You Should See

**Backend Logs**:
```
[InitializeSandbox] Local mode enabled
Skipping sandbox creation
Skipping repository cloning
Working directory: /home/precision7780/repos/temperature_prediction
[Programmer] Reading file: README.md
[Programmer] Editing file: README.md
[Programmer] Changes applied successfully
```

**Local Repository**:
```bash
$ git status
On branch main
Changes not staged for commit:
  modified:   README.md
```

### ❌ What You Were Seeing

**Backend Logs**:
```
Failed to create sandbox environment
Error: Cannot connect to Daytona
```

**Frontend**:
```
An error occurred:
Failed to create sandbox environment.
```

---

## 🎯 Next Steps

1. **Enable local mode** (Step 1-2 above)
2. **Test with simple task**: "Show me the contents of README.md"
3. **If that works**, try: "Add a comment to the README"
4. **Check changes**: `git status` in your repo
5. **Commit manually**: `git commit -am "Changes from OpenSWE"`

---

**Start Here**: Run Step 1 to create the `.env` file! 🚀

