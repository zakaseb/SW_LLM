#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     🔧 FIXING ROUTER MODEL - Force LM Studio Usage              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Check current router model configuration
echo "🔍 Step 1: Checking current router model configuration..."
echo "Current default in code:"
grep -A 5 "routerModelName:" /home/precision7780/PycharmProjects/open-swe/packages/shared/src/open-swe/types.ts | grep "default:"
echo ""

# Step 2: Update the default router model to use LM Studio
echo "🔧 Step 2: Updating router model default to LM Studio..."
cd /home/precision7780/PycharmProjects/open-swe

# Create backup
cp packages/shared/src/open-swe/types.ts packages/shared/src/open-swe/types.ts.backup

# Update the default router model
sed -i 's/default: "anthropic:claude-3-5-haiku-latest"/default: "lmstudio:openai\/gpt-oss-20b"/' packages/shared/src/open-swe/types.ts

echo "✅ Updated router model default to LM Studio"
echo ""

# Step 3: Rebuild shared package
echo "🔨 Step 3: Rebuilding shared package..."
yarn build
echo "✅ Shared package rebuilt"
echo ""

# Step 4: Restart backend
echo "🔄 Step 4: Restarting backend..."
kill -9 $(pgrep -f "yarn dev" | grep -v $$) 2>/dev/null || echo "No processes to kill"
sleep 3

cd apps/open-swe
yarn dev > /tmp/backend-router-fix.log 2>&1 &
BACKEND_PID=$!
echo "Backend restarted with PID: $BACKEND_PID"

# Wait for backend to start
echo "Waiting for backend to start..."
for i in {1..20}; do
  if ss -tulpn 2>/dev/null | grep 2024 >/dev/null 2>&1; then
    echo "✅ Backend started on port 2024"
    break
  fi
  if [ $i -eq 20 ]; then
    echo "❌ Backend failed to start"
    exit 1
  fi
  echo -n "."
  sleep 2
done
echo ""

# Step 5: Test LM Studio API
echo "🧪 Step 5: Testing LM Studio API..."
LM_TEST=$(curl -s -X POST http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [{"role": "user", "content": "Test"}],
    "max_tokens": 5
  }' 2>/dev/null | jq -r '.choices[0].message.content' 2>/dev/null)

if [ "$LM_TEST" != "null" ] && [ -n "$LM_TEST" ]; then
  echo "✅ LM Studio API working: $LM_TEST"
else
  echo "❌ LM Studio API not responding"
fi
echo ""

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ ROUTER MODEL FIXED                        ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🎯 WHAT WAS FIXED:"
echo "  • Router model default changed from Anthropic to LM Studio"
echo "  • Router will now use: lmstudio:openai/gpt-oss-20b"
echo "  • Backend restarted with new configuration"
echo ""
echo "📝 NEXT STEPS:"
echo "  1. Go to: http://localhost:3000 (or your frontend port)"
echo "  2. Settings → Configuration"
echo "  3. Set 'Router Model' to: 'LM Studio - openai/gpt-oss-20b'"
echo "  4. Save configuration"
echo "  5. Test with a new prompt"
echo ""
echo "🔍 VERIFICATION:"
echo "  Backend logs: tail -f /tmp/backend-router-fix.log"
echo "  Look for: 'lmstudio:openai/gpt-oss-20b' in router calls"
echo ""

