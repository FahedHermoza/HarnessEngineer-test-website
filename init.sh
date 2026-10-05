#!/usr/bin/env bash
set -euo pipefail

echo "Repository: $(pwd)"

fail() {
  echo "Harness status: FAILED - $1" >&2
  exit 1
}

if [ ! -f "index.html" ]; then
  echo "Harness status: pre-bootstrap"
  echo "Application stack is not initialized yet."
  echo "Next step: create index.html (feature static-bootstrap)."
  exit 1
fi

echo "Harness status: bootstrapped (static site detected)"
echo "Bootstrap checks:"

if grep -q 'lang="es"' index.html; then
  echo "  [ok] lang=\"es\""
else
  fail "index.html is missing lang=\"es\""
fi

if grep -qE '<title>[^<]+</title>' index.html; then
  echo "  [ok] non-empty <title>"
else
  fail "index.html is missing a non-empty <title>"
fi

if grep -q 'name="viewport"' index.html && grep -q 'width=device-width' index.html; then
  echo '  [ok] viewport meta'
else
  fail "index.html is missing the viewport meta tag"
fi

echo "Serving command: python3 -m http.server 8080 --directory ."
echo "Manual verification: open http://localhost:8080 in a mobile viewport (320/375/768px)."

if [ "${RUN_SERVE_COMMAND:-0}" = "1" ]; then
  exec python3 -m http.server 8080 --directory .
fi
