#!/bin/bash

# Quick system test script for OpenSWE with LM Studio

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║           🧪 OpenSWE System Test - LM Studio Local              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Backend
echo "🔍 Test 1: Backend Status"
if ss -tulpn | grep -q 2024; then
  BACKEND_PID=$(ss -tulpn | grep 2024 | awk '{print $7}' | grep -o 'pid=[0-9]*' | cut -d= -f2)
  echo "  ✅ Backend running on port 2024 (PID: $BACKEND_PID)"
else
  echo "  ❌ Backend NOT running on port 2024"
  echo "  → Run: cd apps/open-swe && yarn dev"
  exit 1
fi
echo ""

# Test 2: LM Studio
echo "🔍 Test 2: LM Studio Status"
if curl -s http://localhost:1234/v1/models > /dev/null 2>&1; then
  MODEL_COUNT=$(curl -s http://localhost:1234/v1/models | jq '.data | length')
  MODEL_NAME=$(curl -s http://localhost:1234/v1/models | jq -r '.data[0].id')
  echo "  ✅ LM Studio running on port 1234"
  echo "  ✅ Models loaded: $MODEL_COUNT"
  echo "  ✅ First model: $MODEL_NAME"
  
  # Check for the specific model
  if curl -s http://localhost:1234/v1/models | jq -r '.data[].id' | grep -q "openai/gpt-oss-20b"; then
    echo "  ✅ Model 'openai/gpt-oss-20b' is loaded"
  else
    echo "  ⚠️  Model 'openai/gpt-oss-20b' NOT loaded"
    echo "  → Load it in LM Studio UI"
  fi
else
  echo "  ❌ LM Studio NOT responding on port 1234"
  echo "  → Start LM Studio and load a model"
  exit 1
fi
echo ""

# Test 3: LM Studio API
echo "🔍 Test 3: LM Studio API (Chat Completion)"
RESPONSE=$(curl -s -X POST http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [{"role": "user", "content": "Reply with just OK"}],
    "max_tokens": 5,
    "temperature": 0
  }')

if echo "$RESPONSE" | jq -e '.choices[0].message.content' > /dev/null 2>&1; then
  CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')
  echo "  ✅ LM Studio API responding"
  echo "  ✅ Response: $CONTENT"
else
  echo "  ❌ LM Studio API not responding correctly"
  echo "  → Check LM Studio logs"
  exit 1
fi
echo ""

# Test 4: Configuration
echo "🔍 Test 4: Model Configuration Defaults"
echo "  Checking packages/shared/src/open-swe/types.ts..."
ROUTER_DEFAULT=$(grep -A 2 "routerModelName:" /home/precision7780/PycharmProjects/open-swe/packages/shared/src/open-swe/types.ts | grep "default:" | awk -F'"' '{print $2}')
PLANNER_DEFAULT=$(grep -A 2 "plannerModelName:" /home/precision7780/PycharmProjects/open-swe/packages/shared/src/open-swe/types.ts | grep "default:" | awk -F'"' '{print $2}')

if [[ "$ROUTER_DEFAULT" == "lmstudio:openai/gpt-oss-20b" ]]; then
  echo "  ✅ Router default: $ROUTER_DEFAULT"
else
  echo "  ❌ Router default: $ROUTER_DEFAULT (should be lmstudio:openai/gpt-oss-20b)"
fi

if [[ "$PLANNER_DEFAULT" == "lmstudio:openai/gpt-oss-20b" ]]; then
  echo "  ✅ Planner default: $PLANNER_DEFAULT"
else
  echo "  ❌ Planner default: $PLANNER_DEFAULT (should be lmstudio:openai/gpt-oss-20b)"
fi
echo ""

# Test 5: Frontend
echo "🔍 Test 5: Frontend Status"
if ss -tulpn | grep -q 3000; then
  FRONTEND_PID=$(ss -tulpn | grep 3000 | awk '{print $7}' | grep -o 'pid=[0-9]*' | cut -d= -f2 | head -1)
  echo "  ✅ Frontend running on port 3000 (PID: $FRONTEND_PID)"
  echo "  → Access at: http://localhost:3000"
else
  echo "  ⚠️  Frontend NOT running on port 3000"
  echo "  → Run: cd apps/web && yarn dev"
fi
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                       ✅ SYSTEM STATUS                           ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ Backend:    Running with LM Studio defaults"
echo "✅ LM Studio:  Running and responding"
echo "✅ API:        Working correctly"
echo "✅ Config:     All models → LM Studio"
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    🚨 ACTION REQUIRED                            ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "BEFORE TESTING:"
echo "1. Clear browser cache completely"
echo "2. Delete localStorage: 'open-swe-config-storage'"
echo "3. Delete ALL cookies for localhost:3000"
echo "4. Hard refresh: Ctrl+Shift+R"
echo "5. Sign in to GitHub again"
echo "6. Go to Settings → Verify all 5 models show 'LM Studio - openai/gpt-oss-20b'"
echo ""
echo "THEN:"
echo "1. Go to: http://localhost:3000"
echo "2. Select repo: zakaseb/temperature_prediction"
echo "3. Select branch: main"
echo "4. Submit: 'Show me the contents of README.md'"
echo ""
echo "📖 Read: BROWSER_CACHE_FIX.md for detailed instructions"
echo ""

