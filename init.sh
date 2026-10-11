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

echo "Design token checks:"

if [ ! -f "styles.css" ]; then
  fail "styles.css is missing"
fi
echo "  [ok] styles.css exists"

if grep -q 'href="styles.css"' index.html; then
  echo "  [ok] index.html links styles.css"
else
  fail "index.html does not link styles.css"
fi

REQUIRED_TOKENS=(
  --color-background
  --color-surface
  --color-surface-container-low
  --color-border
  --color-on-surface
  --color-on-surface-variant
  --color-outline
  --color-primary
  --color-on-primary
  --color-accent
  --color-gradient-1
  --color-gradient-2
  --color-gradient-3
  --color-gradient-4
  --color-gradient-5
  --color-error
  --font-family-base
  --text-headline-lg-font-size
  --text-headline-lg-font-weight
  --text-headline-lg-line-height
  --text-headline-lg-letter-spacing
  --text-headline-md-font-size
  --text-headline-md-font-weight
  --text-headline-md-line-height
  --text-headline-md-letter-spacing
  --text-body-md-font-size
  --text-body-md-font-weight
  --text-body-md-line-height
  --text-body-sm-font-size
  --text-body-sm-font-weight
  --text-body-sm-line-height
  --text-button-label-font-size
  --text-button-label-font-weight
  --text-button-label-line-height
  --text-button-label-letter-spacing
  --text-label-sm-font-size
  --text-label-sm-font-weight
  --text-label-sm-line-height
  --text-label-sm-letter-spacing
  --radius-sm
  --radius-md
  --radius-lg
  --radius-xl
  --radius-full
  --space-gutter
  --space-margin
  --space-xs
  --space-sm
  --space-md
  --space-lg
  --space-xl
)

total_tokens=${#REQUIRED_TOKENS[@]}
present_tokens=0
missing_tokens=0
for token in "${REQUIRED_TOKENS[@]}"; do
  if grep -qE -- "^[[:space:]]*${token}[[:space:]]*:" styles.css; then
    present_tokens=$((present_tokens + 1))
  else
    echo "FAILED - styles.css missing token: $token" >&2
    missing_tokens=$((missing_tokens + 1))
  fi
done

if [ "$missing_tokens" -gt 0 ]; then
  echo "Harness status: FAILED - styles.css is missing $missing_tokens of $total_tokens required design tokens" >&2
  exit 1
fi

echo "  [ok] design tokens present ($present_tokens/$total_tokens)"

echo "Serving command: python3 -m http.server 8080 --directory ."
echo "Manual verification: open http://localhost:8080 in a mobile viewport (320/375/768px)."

if [ "${RUN_SERVE_COMMAND:-0}" = "1" ]; then
  exec python3 -m http.server 8080 --directory .
fi
