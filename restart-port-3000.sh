#!/bin/bash

# Restart script that ENSURES port 3000 is used

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║    🔄 OpenSWE Restart - Force Port 3000                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Kill ALL node processes
echo -e "${YELLOW}Step 1: Killing all Node processes...${NC}"
killall -9 node 2>/dev/null || echo "No processes to kill"
sleep 3
echo -e "${GREEN}✓ All processes stopped${NC}"
echo ""

# Step 2: Ensure port 3000 is free
echo -e "${YELLOW}Step 2: Ensuring port 3000 is free...${NC}"
if lsof -i :3000 >/dev/null 2>&1; then
  echo "Port 3000 is in use, killing process..."
  lsof -ti:3000 | xargs kill -9 2>/dev/null || true
  sleep 2
fi
echo -e "${GREEN}✓ Port 3000 is free${NC}"
echo ""

# Step 3: Verify encryption keys match
echo -e "${YELLOW}Step 3: Verifying encryption keys...${NC}"
BACKEND_KEY=$(grep SECRETS_ENCRYPTION_KEY /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env | cut -d'=' -f2 | tr -d '"' | xargs)
FRONTEND_KEY=$(grep SECRETS_ENCRYPTION_KEY /home/precision7780/PycharmProjects/open-swe/apps/web/.env | cut -d'=' -f2 | tr -d '"' | xargs)

if [ "$BACKEND_KEY" = "$FRONTEND_KEY" ]; then
  echo -e "${GREEN}✓ Encryption keys match${NC}"
else
  echo -e "${RED}✗ Encryption keys DON'T match!${NC}"
  exit 1
fi
echo ""

# Step 4: Verify GitHub App credentials
echo -e "${YELLOW}Step 4: Verifying GitHub App credentials...${NC}"
BACKEND_APP_ID=$(grep "^GITHUB_APP_ID=" /home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env | cut -d'=' -f2 | tr -d '"' | xargs)
if [ "$BACKEND_APP_ID" = "1779334" ]; then
  echo -e "${GREEN}✓ GitHub App credentials configured${NC}"
  echo "  App ID: $BACKEND_APP_ID"
else
  echo -e "${RED}✗ Backend has wrong GitHub App ID: $BACKEND_APP_ID${NC}"
  echo "  Expected: 1779334"
  exit 1
fi
echo ""

# Step 5: Start backend
echo -e "${YELLOW}Step 5: Starting backend...${NC}"
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev > /tmp/backend-port3000.log 2>&1 &
BACKEND_PID=$!
echo "  Backend PID: $BACKEND_PID"

# Wait for backend
echo "  Waiting for backend..."
for i in {1..20}; do
  if ss -tulpn 2>/dev/null | grep 2024 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend started on port 2024${NC}"
    break
  fi
  if [ $i -eq 20 ]; then
    echo -e "${RED}✗ Backend failed to start${NC}"
    exit 1
  fi
  echo -n "."
  sleep 2
done
echo ""

# Step 6: Start frontend on port 3000
echo -e "${YELLOW}Step 6: Starting frontend on port 3000...${NC}"
cd /home/precision7780/PycharmProjects/open-swe/apps/web
PORT=3000 yarn dev > /tmp/frontend-port3000.log 2>&1 &
FRONTEND_PID=$!
echo "  Frontend PID: $FRONTEND_PID"

# Wait for frontend
echo "  Waiting for frontend..."
for i in {1..30}; do
  if ss -tulpn 2>/dev/null | grep ":3000" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend started on port 3000${NC}"
    break
  fi
  if [ $i -eq 30 ]; then
    echo -e "${RED}✗ Frontend failed to start on port 3000${NC}"
    exit 1
  fi
  echo -n "."
  sleep 2
done
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              ✅ Services Running on Port 3000            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Access Points:"
echo "  Frontend:  http://localhost:3000"
echo "  Network:   http://192.168.218.132:3000"
echo "  Backend:   http://localhost:2024"
echo ""
echo "📊 Process IDs:"
echo "  Backend:  $BACKEND_PID"
echo "  Frontend: $FRONTEND_PID"
echo ""
echo "📝 Logs:"
echo "  Backend:  tail -f /tmp/backend-port3000.log"
echo "  Frontend: tail -f /tmp/frontend-port3000.log"
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         🚨 REMEMBER: Clear Browser Data First!          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "1. Open DevTools (F12) → Application"
echo "2. Delete ALL cookies for localhost"
echo "3. Clear Local Storage → 'open-swe-config-storage'"
echo "4. Clear Session Storage"
echo "5. Hard refresh: Ctrl+Shift+R"
echo ""
echo "Then: http://localhost:3000 → Sign in → Configure models → Test!"
echo ""
