#!/bin/bash

# Clean Restart Script for OpenSWE
# Fixes decryption errors by starting fresh

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║     🔄 OpenSWE Clean Restart (Fix Decryption Errors)    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Kill all processes
echo -e "${YELLOW}Step 1: Stopping all Node processes...${NC}"
killall -9 node 2>/dev/null || echo "No processes to kill"
sleep 3
echo -e "${GREEN}✓ All processes stopped${NC}"
echo ""

# Step 2: Verify encryption keys match
echo -e "${YELLOW}Step 2: Verifying encryption keys...${NC}"
BACKEND_KEY=$(grep SECRETS_ENCRYPTION_KEY /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env | cut -d'=' -f2 | tr -d '"' | xargs)
FRONTEND_KEY=$(grep SECRETS_ENCRYPTION_KEY /home/precision7780/PycharmProjects/open-swe/apps/web/.env | cut -d'=' -f2 | tr -d '"' | xargs)

if [ "$BACKEND_KEY" = "$FRONTEND_KEY" ]; then
  echo -e "${GREEN}✓ Encryption keys match${NC}"
  echo "  Key: ${BACKEND_KEY:0:16}...${BACKEND_KEY: -16}"
else
  echo -e "${RED}✗ Encryption keys DON'T match!${NC}"
  echo "  Backend:  $BACKEND_KEY"
  echo "  Frontend: $FRONTEND_KEY"
  echo ""
  echo -e "${RED}ERROR: Fix the keys first before continuing!${NC}"
  exit 1
fi
echo ""

# Step 3: Start backend
echo -e "${YELLOW}Step 3: Starting backend...${NC}"
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev > /tmp/backend-clean-restart.log 2>&1 &
BACKEND_PID=$!
echo "  Backend PID: $BACKEND_PID"

# Wait for backend
echo "  Waiting for backend to start..."
for i in {1..20}; do
  if ss -tulpn 2>/dev/null | grep 2024 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend started on port 2024${NC}"
    break
  fi
  if [ $i -eq 20 ]; then
    echo -e "${RED}✗ Backend failed to start${NC}"
    echo "Check logs: tail -f /tmp/backend-clean-restart.log"
    exit 1
  fi
  echo -n "."
  sleep 2
done
echo ""

# Step 4: Check for decryption errors in backend
sleep 2
if tail -50 /tmp/backend-clean-restart.log | grep -q "Failed to decrypt"; then
  echo -e "${RED}⚠️  Backend has decryption errors in logs${NC}"
  echo "This is expected if old encrypted data exists"
  echo "Continue with browser cleanup steps below"
else
  echo -e "${GREEN}✓ No decryption errors (yet)${NC}"
fi
echo ""

# Step 5: Start frontend
echo -e "${YELLOW}Step 4: Starting frontend...${NC}"
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev > /tmp/frontend-clean-restart.log 2>&1 &
FRONTEND_PID=$!
echo "  Frontend PID: $FRONTEND_PID"

# Wait for frontend
echo "  Waiting for frontend to start..."
for i in {1..30}; do
  if ss -tulpn 2>/dev/null | grep -E "3000|3001|3002|3003|3004|3005" >/dev/null 2>&1; then
    FRONTEND_PORT=$(ss -tulpn 2>/dev/null | grep "next-server" | head -1 | awk '{print $5}' | cut -d':' -f2)
    echo -e "${GREEN}✓ Frontend started on port $FRONTEND_PORT${NC}"
    break
  fi
  if [ $i -eq 30 ]; then
    echo -e "${RED}✗ Frontend failed to start${NC}"
    echo "Check logs: tail -f /tmp/frontend-clean-restart.log"
    exit 1
  fi
  echo -n "."
  sleep 2
done
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              ✅ Services Started Successfully            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Access Points:"
echo "  Frontend:  http://localhost:$FRONTEND_PORT"
echo "  Network:   http://192.168.218.132:$FRONTEND_PORT"
echo "  Backend:   http://localhost:2024"
echo ""
echo "📊 Process IDs:"
echo "  Backend:  $BACKEND_PID"
echo "  Frontend: $FRONTEND_PID"
echo ""
echo "📝 Logs:"
echo "  Backend:  tail -f /tmp/backend-clean-restart.log"
echo "  Frontend: tail -f /tmp/frontend-clean-restart.log"
echo ""

# Check GitHub App callback URL
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              🚨 CRITICAL: Action Required                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${YELLOW}1. CLEAR BROWSER DATA (REQUIRED!)${NC}"
echo "   Open DevTools (F12) → Application tab:"
echo "   ✓ Delete ALL cookies for localhost"
echo "   ✓ Clear Local Storage → 'open-swe-config-storage'"
echo "   ✓ Clear Session Storage"
echo "   ✓ Hard refresh: Ctrl+Shift+R"
echo ""
echo -e "${YELLOW}2. CHECK PORT MISMATCH${NC}"
if [ "$FRONTEND_PORT" = "3000" ]; then
  echo -e "   ${GREEN}✓ Frontend on port 3000 (matches GitHub App callback)${NC}"
else
  echo -e "   ${RED}⚠️  Frontend on port $FRONTEND_PORT${NC}"
  echo "   GitHub App callback URL is set to: http://localhost:3000/api/auth/github/callback"
  echo ""
  echo "   Choose ONE:"
  echo "   A) Restart to get port 3000:"
  echo "      killall -9 node && sleep 3 && ./clean-restart.sh"
  echo ""
  echo "   B) Add this to GitHub App callback URLs:"
  echo "      http://localhost:$FRONTEND_PORT/api/auth/github/callback"
fi
echo ""
echo -e "${YELLOW}3. RE-AUTHENTICATE${NC}"
echo "   ✓ Open: http://localhost:$FRONTEND_PORT"
echo "   ✓ Sign in with GitHub (encrypts tokens with NEW key)"
echo "   ✓ Complete OAuth flow"
echo ""
echo -e "${YELLOW}4. CONFIGURE MODELS${NC}"
echo "   ✓ Settings → Configuration"
echo "   ✓ Set ALL 5 dropdowns to: LM Studio - openai/gpt-oss-20b"
echo "   ✓ Save"
echo ""
echo -e "${YELLOW}5. TEST${NC}"
echo "   ✓ Select repository: zakaseb/temperature_prediction"
echo "   ✓ Branch: main"
echo "   ✓ Submit: 'Show me the contents of README.md'"
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           After browser cleanup, you're ready! 🚀        ║"
echo "╚══════════════════════════════════════════════════════════╝"

