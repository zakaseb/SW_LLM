#!/bin/bash

# Open SWE - Server Restart Script
# This script cleans up and restarts all services properly

echo "🔧 Open SWE - Restarting Services..."
echo ""

# Step 1: Clean up any running processes
echo "📋 Step 1: Cleaning up existing processes..."
pkill -f "langgraph.*dev" 2>/dev/null
pkill -f "next-server" 2>/dev/null
sleep 2

# Verify ports are free
echo "✓ Checking ports..."
if lsof -ti:2024 >/dev/null 2>&1; then
    echo "⚠️  Warning: Port 2024 still occupied, force killing..."
    kill -9 $(lsof -ti:2024) 2>/dev/null
fi

if lsof -ti:3000 >/dev/null 2>&1; then
    echo "⚠️  Warning: Port 3000 still occupied, force killing..."
    kill -9 $(lsof -ti:3000) 2>/dev/null
fi

sleep 1
echo "✓ Ports 2024 and 3000 are now free"
echo ""

# Step 2: Verify LM Studio
echo "📋 Step 2: Checking LM Studio..."
if lsof -ti:1234 >/dev/null 2>&1; then
    echo "✓ LM Studio is running on port 1234"
else
    echo "❌ ERROR: LM Studio is NOT running!"
    echo "   Please start LM Studio and load a model before continuing."
    exit 1
fi
echo ""

# Step 3: Start LangGraph Server
echo "📋 Step 3: Starting LangGraph server..."
echo "   Opening new terminal for LangGraph server..."
gnome-terminal -- bash -c "cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe && echo '🚀 Starting LangGraph Server...' && yarn dev; exec bash" 2>/dev/null || \
xterm -e "cd /home/precision7780/PycharmProjects/open-swe/apps/open-swe && echo '🚀 Starting LangGraph Server...' && yarn dev; exec bash" 2>/dev/null || \
echo "⚠️  Could not open new terminal. Please manually run: cd apps/open-swe && yarn dev"

echo "   Waiting for LangGraph server to start..."
sleep 5

# Check if LangGraph is running
for i in {1..10}; do
    if lsof -ti:2024 >/dev/null 2>&1; then
        echo "✓ LangGraph server is running on port 2024"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ LangGraph server did not start. Check the terminal window."
        exit 1
    fi
    sleep 1
done
echo ""

# Step 4: Start Web App
echo "📋 Step 4: Starting Web App..."
echo "   Opening new terminal for Web App..."
gnome-terminal -- bash -c "cd /home/precision7780/PycharmProjects/open-swe/apps/web && echo '🌐 Starting Web App...' && yarn dev; exec bash" 2>/dev/null || \
xterm -e "cd /home/precision7780/PycharmProjects/open-swe/apps/web && echo '🌐 Starting Web App...' && yarn dev; exec bash" 2>/dev/null || \
echo "⚠️  Could not open new terminal. Please manually run: cd apps/web && yarn dev"

echo "   Waiting for Web App to start..."
sleep 5

# Check if Web App is running
for i in {1..10}; do
    if lsof -ti:3000 >/dev/null 2>&1; then
        echo "✓ Web App is running on port 3000"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ Web App did not start. Check the terminal window."
        exit 1
    fi
    sleep 1
done
echo ""

# Final summary
echo "✅ All services started successfully!"
echo ""
echo "📝 Next Steps:"
echo "   1. Open browser: http://localhost:3000"
echo "   2. Click 'Sign in with GitHub'"
echo "   3. Complete OAuth authentication"
echo "   4. Select your repository and branch"
echo "   5. In Settings, choose model: 'LM Studio (Local)'"
echo "   6. Start coding!"
echo ""
echo "📚 For troubleshooting, see: STARTUP_INSTRUCTIONS.md"

