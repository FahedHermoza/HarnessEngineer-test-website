#!/usr/bin/env bash
set -euo pipefail

echo "Repository: $(pwd)"

if [ -f "index.html" ]; then
  echo "Harness status: bootstrapped (static site detected)"
  echo "Serving command: python3 -m http.server 8080 --directory ."
  echo "Manual verification: abrir http://localhost:8080 en un viewport móvil."
  if [ "${RUN_SERVE_COMMAND:-0}" = "1" ]; then
    exec python3 -m http.server 8080 --directory .
  fi
else
  echo "Harness status: pre-bootstrap"
  echo "Application stack is not initialized yet."
  echo "Next step: choose the first feature from feature_list.json and perform technical bootstrap."
  echo "Expected future commands after bootstrap:"
  echo "  - Serve: python3 -m http.server 8080 --directory ."
  echo "  - Verify: manual browser checks per feature (iOS/Android, viewports 320/375/768px)."
fi
