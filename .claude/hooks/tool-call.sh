#!/bin/bash

# Auto-build TypeScript when source files are edited
# This hook runs after Edit or Write tool calls

TOOL_NAME="$1"
FILE_PATH="$2"

# Check if a TypeScript source file was modified
if [[ "$FILE_PATH" == */src/*.ts ]]; then
  echo "📦 TypeScript file modified, rebuilding..."
  npm run build 2>&1 | grep -v "^$" | head -20

  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ Build successful"
  else
    echo "✗ Build failed - check errors above"
  fi
fi
