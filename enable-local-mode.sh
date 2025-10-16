#!/bin/bash

# Script to Enable Local Mode for OpenSWE
# This allows OpenSWE to work directly with local filesystem without Docker/Daytona

set -e

echo "=================================================="
echo "🏠 Enabling OpenSWE Local Mode"
echo "=================================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Create .env file
echo -e "${YELLOW}Step 1: Creating backend .env file...${NC}"

ENV_FILE="/home/precision7780/PycharmProjects/open-swe/apps/open-swe/.env"

cat > "$ENV_FILE" << 'EOF'
# Enable Local Mode (works with local filesystem, no Docker/Daytona needed)
OPEN_SWE_LOCAL_MODE=true

# LM Studio API URL
LMSTUDIO_BASE_URL=http://localhost:1234/v1
EOF

echo -e "${GREEN}✓ Created $ENV_FILE${NC}"
echo ""

# Display contents
echo "Contents:"
cat "$ENV_FILE"
echo ""

# Step 2: Kill and restart backend
echo -e "${YELLOW}Step 2: Restarting backend...${NC}"

# Kill existing backend
pkill -9 -f "open-swe.*yarn dev" 2>/dev/null || echo "No existing backend process found"
sleep 2

# Start backend
echo "Starting backend with local mode enabled..."
cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe
yarn dev > /tmp/openswe-backend-local.log 2>&1 &
BACKEND_PID=$!

echo "Backend PID: $BACKEND_PID"
echo "Waiting for backend to start..."

# Wait for backend to start
for i in {1..20}; do
    if curl -s http://localhost:2024/ok >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Backend started successfully on http://localhost:2024${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo "Backend is taking longer than expected. Check logs:"
        echo "  tail -f /tmp/openswe-backend-local.log"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Summary
echo "=================================================="
echo -e "${GREEN}✅ Local Mode Enabled!${NC}"
echo "=================================================="
echo ""
echo "What changed:"
echo "  ✓ Created $ENV_FILE"
echo "  ✓ Set OPEN_SWE_LOCAL_MODE=true"
echo "  ✓ Backend restarted with local mode"
echo ""
echo "How it works now:"
echo "  • NO Docker/Daytona required"
echo "  • Works directly on local filesystem"
echo "  • Faster startup (no container creation)"
echo "  • You control commits manually"
echo ""
echo "Backend logs:"
echo "  tail -f /tmp/openswe-backend-local.log"
echo ""
echo "Next steps:"
echo "  1. Go to http://localhost:3000"
echo "  2. Select a repository"
echo "  3. Submit: 'Show me the contents of README.md'"
echo "  4. Should work without sandbox errors!"
echo ""
echo "Backend PID: $BACKEND_PID"
echo "To stop: kill $BACKEND_PID"
echo "=================================================="

