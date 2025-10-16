#!/bin/bash

# Complete Reset Script for OpenSWE + LM Studio Integration
# This script will:
# 1. Kill all processes
# 2. Rebuild shared package
# 3. Start backend
# 4. Start frontend

set -e  # Exit on error

echo "=================================================="
echo "🔧 OpenSWE Complete Reset Script"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Kill all processes
echo -e "${YELLOW}Step 1: Killing all OpenSWE processes...${NC}"
pkill -9 -f "open-swe.*yarn dev" 2>/dev/null || echo "No backend process found"
pkill -9 -f "apps/web.*yarn dev" 2>/dev/null || echo "No frontend process found"
sleep 2

# Verify ports are clear
if ss -tulpn 2>/dev/null | grep -E "(2024|3000|3001)" >/dev/null 2>&1; then
    echo -e "${RED}⚠️  Warning: Some ports still in use${NC}"
    ss -tulpn 2>/dev/null | grep -E "(2024|3000|3001)"
else
    echo -e "${GREEN}✓ All ports cleared${NC}"
fi
echo ""

# Step 2: Rebuild shared package
echo -e "${YELLOW}Step 2: Rebuilding shared package...${NC}"
cd /home/precision7780/PycharmProjects/open-swe
yarn workspace @open-swe/shared build

if [ -f "packages/shared/dist/open-swe/types.js" ]; then
    echo -e "${GREEN}✓ Shared package built successfully${NC}"
else
    echo -e "${RED}✗ Shared package build failed!${NC}"
    exit 1
fi
echo ""

# Step 3: Verify LM Studio
echo -e "${YELLOW}Step 3: Checking LM Studio...${NC}"
if curl -s http://localhost:1234/v1/models >/dev/null 2>&1; then
    MODEL_INFO=$(curl -s http://localhost:1234/v1/models | grep -o '"id":"[^"]*"' | head -1)
    echo -e "${GREEN}✓ LM Studio is running${NC}"
    echo "   Model: $MODEL_INFO"
else
    echo -e "${RED}⚠️  LM Studio not responding on port 1234${NC}"
    echo "   Please start LM Studio and load model: openai/gpt-oss-20b"
fi
echo ""

# Step 4: Start backend
echo -e "${YELLOW}Step 4: Starting backend...${NC}"
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev > /tmp/openswe-backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend PID: $BACKEND_PID"

# Wait for backend to start
echo "Waiting for backend to start..."
for i in {1..20}; do
    if curl -s http://localhost:2024/ok >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Backend started successfully on http://localhost:2024${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}✗ Backend failed to start. Check logs: tail -f /tmp/openswe-backend.log${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Step 5: Start frontend
echo -e "${YELLOW}Step 5: Starting frontend...${NC}"
cd /home/precision7780/PycharmProjects/open-swe/apps/web
yarn dev > /tmp/openswe-frontend.log 2>&1 &
FRONTEND_PID=$!
echo "Frontend PID: $FRONTEND_PID"

# Wait for frontend to start
echo "Waiting for frontend to start..."
for i in {1..30}; do
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Frontend started successfully on http://localhost:3000${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}✗ Frontend failed to start. Check logs: tail -f /tmp/openswe-frontend.log${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Summary
echo "=================================================="
echo -e "${GREEN}✅ All services started successfully!${NC}"
echo "=================================================="
echo ""
echo "Next Steps:"
echo "1. Clear browser localStorage:"
echo "   - Open http://localhost:3000"
echo "   - Press F12 to open console"
echo "   - Run: localStorage.removeItem('open-swe-config-storage'); location.reload(true);"
echo ""
echo "2. Configure models:"
echo "   - Go to http://localhost:3000/settings?tab=configuration"
echo "   - Select 'LM Studio - openai/gpt-oss-20b' for ALL 5 model fields"
echo ""
echo "3. Hard refresh: Ctrl + Shift + R"
echo ""
echo "4. Test: Submit a task!"
echo ""
echo "Logs:"
echo "  Backend:  tail -f /tmp/openswe-backend.log"
echo "  Frontend: tail -f /tmp/openswe-frontend.log"
echo ""
echo "PIDs:"
echo "  Backend:  $BACKEND_PID"
echo "  Frontend: $FRONTEND_PID"
echo ""
echo "To stop:"
echo "  kill $BACKEND_PID $FRONTEND_PID"
echo "=================================================="

