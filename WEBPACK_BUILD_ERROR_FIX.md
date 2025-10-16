# Webpack Build Error - Fix Documentation

## Problem

When starting the Next.js dev server, a webpack module error occurred:

```
Error: Cannot find module './vendor-chunks/fast-content-type-parse.js'
Require stack:
- /home/precision7780/PycharmProjects/open-swe/apps/web/.next/server/webpack-runtime.js
- /home/precision7780/PycharmProjects/open-swe/apps/web/.next/server/app/api/[..._path]/route.js
```

This prevented the `/api/[..._path]` route from loading, which is the main API proxy for LangGraph requests.

## Root Cause

**Corrupted Next.js build cache** in the `.next` directory.

This can happen when:
- Dependencies are updated
- Build process is interrupted
- File system issues
- Hot module replacement (HMR) conflicts

## Solution

### Step 1: Stop All Running Servers
```bash
pkill -f "yarn dev"
```

### Step 2: Clean the Next.js Build Cache
```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/web
rm -rf .next
```

### Step 3: Reinstall Dependencies
```bash
cd /home/precision7780/PycharmProjects/open-swe
yarn install
```

### Step 4: Restart the Dev Server
```bash
cd /home/precision7780/PycharmProjects/open-swe/apps/web
PORT=3001 yarn dev
```

## Results

### Before Fix: ❌
```
HTTP 500: Cannot find module './vendor-chunks/fast-content-type-parse.js'
```

### After Fix: ✅
```
✓ Compiled /api/[..._path] in 1450ms (400 modules)
GET /api/threads/... 500 in 2409ms
```

The API route now compiles successfully! The HTTP 500 is now a different issue (backend LangGraph server not running), not a webpack error.

## Why This Worked

1. **Removed corrupted cache**: The `.next` directory contained stale or corrupted webpack chunks
2. **Fresh build**: Next.js rebuilds all routes from scratch
3. **Correct module resolution**: Webpack can now find all vendor chunks correctly

## When to Use This Fix

Apply this fix whenever you see:
- `Cannot find module './vendor-chunks/...'` errors
- `Module not found` errors after updating dependencies
- Webpack compilation errors that don't make sense
- Stale build artifacts causing issues

## Related Files

- **Route**: `apps/web/src/app/api/[..._path]/route.ts` - API proxy to LangGraph
- **Build Dir**: `apps/web/.next/` - Next.js build cache (can be safely deleted)
- **Dependencies**: Uses `langgraph-nextjs-api-passthrough` package

## Prevention

To avoid this issue in the future:

1. **After dependency updates**, clean the build cache:
   ```bash
   rm -rf apps/web/.next
   ```

2. **After git pulls** with package changes, reinstall:
   ```bash
   yarn install
   ```

3. **If HMR acts strange**, restart with a clean build:
   ```bash
   pkill -f "yarn dev"
   rm -rf apps/web/.next
   yarn dev
   ```

## Current Status

✅ **Webpack Error**: FIXED
✅ **API Route**: Compiling successfully
✅ **Next.js Server**: Running on http://localhost:3001

⚠️ **LangGraph Server**: Still needs to be started on port 2024

## Next Steps

The frontend is now working correctly. To complete the setup:

1. **Start LangGraph Server**:
   ```bash
   cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
   yarn dev
   ```

2. **Start LM Studio**: On port 1234

3. **Configure Models**: In Settings → Configuration

Then the full workflow will work end-to-end!

---

**The webpack build error is completely resolved!** 🎉

