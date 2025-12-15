#!/bin/bash

# Display helpful information when starting a Claude Code session

echo ""
echo "🔧 RouterOS Diagnostics Tool - Ready"
echo ""
echo "📋 Available Commands:"
echo "  /diagnose            - Run full diagnostics on all routers"
echo "  /diagnose-router     - Run diagnostics on specific router"
echo "  /diagnose-group      - Run diagnostics on router group"
echo "  /list-routers        - List all configured routers"
echo "  /system-check        - Quick system diagnostics only"
echo "  /interface-check     - Interface diagnostics only"
echo "  /routing-check       - Routing diagnostics only"
echo ""

# Count routers
if [ -f "routers.json" ]; then
  ROUTER_COUNT=$(node -e "console.log(JSON.parse(require('fs').readFileSync('routers.json', 'utf-8')).routers.length)")
  echo "📊 Configured Routers: $ROUTER_COUNT"
else
  echo "⚠️  No routers.json found - run the WinBox parser first"
fi

echo ""
