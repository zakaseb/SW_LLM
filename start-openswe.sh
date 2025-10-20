#!/bin/bash

# Complete OpenSWE Startup Script
# Starts backend and frontend with all required configuration

set -e

echo "=================================================="
echo "🚀 Starting OpenSWE with LM Studio Integration"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Kill all existing processes
echo -e "${YELLOW}Step 1: Cleaning up existing processes...${NC}"
killall -9 node 2>/dev/null || echo "No existing node processes"
sleep 3
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

# Step 2: Build packages
echo -e "${YELLOW}Step 2: Building packages...${NC}"
cd /home/precision7780/PycharmProjects/open-swe

echo "  Building shared package..."
yarn workspace @open-swe/shared build > /dev/null 2>&1
echo -e "${GREEN}  ✓ Shared package built${NC}"

echo "  Building open-swe package..."
yarn workspace @open-swe/agent build > /dev/null 2>&1
echo -e "${GREEN}  ✓ Open-swe package built${NC}"
echo ""

# Step 3: Generate encryption key
echo -e "${YELLOW}Step 3: Generating encryption key...${NC}"
ENCRYPTION_KEY=$(openssl rand -hex 32)
echo -e "${GREEN}✓ Encryption key generated${NC}"
echo ""

# Step 4: Check LM Studio
echo -e "${YELLOW}Step 4: Checking LM Studio...${NC}"
if curl -s http://localhost:1234/v1/models >/dev/null 2>&1; then
    MODEL_INFO=$(curl -s http://localhost:1234/v1/models | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo -e "${GREEN}✓ LM Studio is running${NC}"
    echo "  Model: $MODEL_INFO"
else
    echo -e "${RED}⚠️  LM Studio not responding on port 1234${NC}"
    echo "  Please start LM Studio and load model: openai/gpt-oss-20b"
    echo "  Press Ctrl+C to exit, or any key to continue anyway..."
    read -n 1 -s -r
fi
echo ""

# Step 5: Start backend
echo -e "${YELLOW}Step 5: Starting backend...${NC}"
cd /home/precision7780/PycharmProjects/open-swe
OPEN_SWE_LOCAL_MODE=true \
LMSTUDIO_BASE_URL=http://localhost:1234/v1 \
SECRETS_ENCRYPTION_KEY=$ENCRYPTION_KEY \
yarn workspace @open-swe/agent dev > /tmp/openswe-backend.log 2>&1 &
BACKEND_PID=$!

echo "  Backend PID: $BACKEND_PID"
echo "  Waiting for backend to start..."

# Wait for backend
for i in {1..20}; do
    if ss -tulpn 2>/dev/null | grep 2024 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Backend started on http://localhost:2024${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}✗ Backend failed to start${NC}"
        echo "  Check logs: tail -f /tmp/openswe-backend.log"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Step 6: Start frontend
echo -e "${YELLOW}Step 6: Starting frontend...${NC}"
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev > /tmp/openswe-frontend.log 2>&1 &
FRONTEND_PID=$!

echo "  Frontend PID: $FRONTEND_PID"
echo "  Waiting for frontend to start..."

# Wait for frontend
for i in {1..30}; do
    if ss -tulpn 2>/dev/null | grep -E "3000|3001|3002|3003|3004" >/dev/null 2>&1; then
        FRONTEND_PORT=$(ss -tulpn 2>/dev/null | grep "next-server" | head -1 | awk '{print $5}' | cut -d':' -f2)
        echo -e "${GREEN}✓ Frontend started on http://localhost:$FRONTEND_PORT${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}✗ Frontend failed to start${NC}"
        echo "  Check logs: tail -f /tmp/openswe-frontend.log"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Summary
echo "=================================================="
echo -e "${GREEN}✅ OpenSWE Started Successfully!${NC}"
echo "=================================================="
echo ""
echo "🌐 Access Points:"
echo "  Frontend: http://localhost:$FRONTEND_PORT"
echo "  Network:  http://192.168.218.132:$FRONTEND_PORT"
echo "  Backend:  http://localhost:2024"
echo ""
echo "📊 Process IDs:"
echo "  Backend:  $BACKEND_PID"
echo "  Frontend: $FRONTEND_PID"
echo ""
echo "📝 Logs:"
echo "  Backend:  tail -f /tmp/openswe-backend.log"
echo "  Frontend: tail -f /tmp/openswe-frontend.log"
echo ""
echo "🛑 To Stop:"
echo "  kill $BACKEND_PID $FRONTEND_PID"
echo "  OR: killall -9 node"
echo ""
echo "🎯 Next Steps:"
echo "  1. Open http://localhost:$FRONTEND_PORT in your browser"
echo "  2. Sign in with GitHub"
echo "  3. Select repository: zakaseb/temperature_prediction"
echo "  4. Branch: main"
echo "  5. Submit task: 'Show me the contents of README.md'"
echo ""
echo "✨ Configuration:"
echo "  ✅ Local Mode: Enabled (no Docker needed)"
echo "  ✅ LM Studio: http://localhost:1234/v1"
echo "  ✅ Model: openai/gpt-oss-20b"
echo "  ✅ Encryption: $(echo $ENCRYPTION_KEY | cut -c1-8)... (32 bytes)"
echo ""
echo "=================================================="
echo "OpenSWE is ready! 🚀"
echo "=================================================="

