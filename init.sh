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

echo "Component checks:"

LINK_BUTTON_RULE=$(awk '
  /^[[:space:]]*\.link-button[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$LINK_BUTTON_RULE" ]; then
  fail "styles.css is missing the .link-button base rule"
fi
echo "  [ok] .link-button base rule exists"

LINK_BUTTON_CONTRACT=(
  'width: 100%;'
  'height: 48px;'
  'padding: 0 1.25rem;'
  'border-radius: var(--radius-md);'
  'justify-content: space-between;'
  'text-transform: uppercase;'
)

contract_total=${#LINK_BUTTON_CONTRACT[@]}
contract_present=0
contract_missing=0
for declaration in "${LINK_BUTTON_CONTRACT[@]}"; do
  case "$LINK_BUTTON_RULE" in
    *"$declaration"*)
      contract_present=$((contract_present + 1))
      ;;
    *)
      echo "FAILED - .link-button base rule missing declaration: $declaration" >&2
      contract_missing=$((contract_missing + 1))
      ;;
  esac
done

if [ "$contract_missing" -gt 0 ]; then
  echo "Harness status: FAILED - .link-button component contract is missing $contract_missing of $contract_total required declarations" >&2
  exit 1
fi

echo "  [ok] link button component contract ($contract_present/$contract_total)"

if grep -qF '@media (prefers-reduced-motion: reduce)' styles.css; then
  echo "  [ok] prefers-reduced-motion media query"
else
  fail "styles.css is missing @media (prefers-reduced-motion: reduce)"
fi

echo "Page shell checks:"

if grep -q 'class="page"' index.html && grep -q 'class="card"' index.html; then
  echo "  [ok] page shell markup"
else
  fail "index.html is missing class=\"page\" or class=\"card\""
fi

if grep -qE '^\.page[[:space:]]*\{' styles.css && grep -qE '^\.card[[:space:]]*\{' styles.css; then
  echo "  [ok] page shell styles"
else
  fail "styles.css is missing the .page or .card rule"
fi

if grep -qF 'min(400px, calc(100vw - 2rem))' styles.css; then
  echo "  [ok] card width contract"
else
  fail "styles.css is missing the card width contract min(400px, calc(100vw - 2rem))"
fi

echo "Profile checks:"

if grep -qF 'class="profile-avatar"' index.html \
  && grep -qF 'src="assets/avatar.jpg"' index.html \
  && grep -qF 'alt="Retrato de Fahed Hermoza"' index.html; then
  echo "  [ok] profile avatar markup"
else
  fail "index.html is missing the profile avatar markup (class=\"profile-avatar\", src=\"assets/avatar.jpg\" or alt=\"Retrato de Fahed Hermoza\")"
fi

if [ -f "assets/avatar.jpg" ] && [ -s "assets/avatar.jpg" ]; then
  echo "  [ok] avatar asset exists"
else
  fail "assets/avatar.jpg is missing or empty"
fi

PROFILE_AVATAR_RULE=$(awk '
  /^[[:space:]]*\.profile-avatar[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$PROFILE_AVATAR_RULE" ]; then
  fail "styles.css is missing the .profile-avatar base rule"
fi
echo "  [ok] .profile-avatar base rule exists"

PROFILE_AVATAR_CONTRACT=(
  'width: 88px;'
  'height: 88px;'
  'border-radius: var(--radius-full);'
  'object-fit: cover;'
  'box-shadow: 0 0 0 3px var(--color-surface);'
)

profile_contract_total=${#PROFILE_AVATAR_CONTRACT[@]}
profile_contract_present=0
profile_contract_missing=0
for declaration in "${PROFILE_AVATAR_CONTRACT[@]}"; do
  case "$PROFILE_AVATAR_RULE" in
    *"$declaration"*)
      profile_contract_present=$((profile_contract_present + 1))
      ;;
    *)
      echo "FAILED - .profile-avatar base rule missing declaration: $declaration" >&2
      profile_contract_missing=$((profile_contract_missing + 1))
      ;;
  esac
done

if [ "$profile_contract_missing" -gt 0 ]; then
  echo "Harness status: FAILED - profile avatar contract is missing $profile_contract_missing of $profile_contract_total required declarations" >&2
  exit 1
fi

echo "  [ok] profile avatar contract ($profile_contract_present/$profile_contract_total)"

echo "Page footer checks:"

if grep -qF '<footer class="page-footer">' index.html && grep -qF 'class="page-footer__link"' index.html; then
  echo "  [ok] page footer markup"
else
  fail "index.html is missing the page footer markup"
fi

if grep -qF 'href="mailto:fahedhermoza@gmail.com"' index.html; then
  :
else
  fail "index.html is missing the page footer email destination mailto:fahedhermoza@gmail.com"
fi

if grep -qF 'href="https://www.instagram.com/fahedhermoza/"' index.html; then
  :
else
  fail "index.html is missing the page footer handle destination https://www.instagram.com/fahedhermoza/"
fi

echo "  [ok] page footer destinations"

PAGE_FOOTER_RULE=$(awk '
  /^[[:space:]]*\.page-footer[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$PAGE_FOOTER_RULE" ]; then
  fail "styles.css is missing the .page-footer base rule"
fi

PAGE_FOOTER_CONTRACT=(
  'border-top: 1px solid var(--color-border);'
  'text-align: center;'
  'padding: var(--space-lg);'
  'font-size: var(--text-body-md-font-size);'
  'color: var(--color-on-surface);'
)

footer_total=${#PAGE_FOOTER_CONTRACT[@]}
footer_present=0
footer_missing=0
for declaration in "${PAGE_FOOTER_CONTRACT[@]}"; do
  case "$PAGE_FOOTER_RULE" in
    *"$declaration"*)
      footer_present=$((footer_present + 1))
      ;;
    *)
      echo "FAILED - .page-footer base rule missing declaration: $declaration" >&2
      footer_missing=$((footer_missing + 1))
      ;;
  esac
done

if [ "$footer_missing" -gt 0 ]; then
  echo "Harness status: FAILED - page footer contract is missing $footer_missing of $footer_total required declarations" >&2
  exit 1
fi

echo "  [ok] page footer contract ($footer_present/$footer_total)"

PAGE_FOOTER_LINK_RULE=$(awk '
  /^[[:space:]]*\.page-footer__link[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$PAGE_FOOTER_LINK_RULE" ]; then
  fail "styles.css is missing the .page-footer__link base rule"
fi

PAGE_FOOTER_LINK_CONTRACT=(
  'color: var(--color-accent);'
  'text-decoration: underline;'
  'text-underline-offset: 2px;'
)

link_total=${#PAGE_FOOTER_LINK_CONTRACT[@]}
link_present=0
link_missing=0
for declaration in "${PAGE_FOOTER_LINK_CONTRACT[@]}"; do
  case "$PAGE_FOOTER_LINK_RULE" in
    *"$declaration"*)
      link_present=$((link_present + 1))
      ;;
    *)
      echo "FAILED - .page-footer__link base rule missing declaration: $declaration" >&2
      link_missing=$((link_missing + 1))
      ;;
  esac
done

if [ "$link_missing" -gt 0 ]; then
  echo "Harness status: FAILED - page footer link accent is missing $link_missing of $link_total required declarations" >&2
  exit 1
fi

echo "  [ok] page footer link accent"

PAGE_FOOTER_FOCUS_RULE=$(awk '
  /^[[:space:]]*\.page-footer__link:focus-visible[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$PAGE_FOOTER_FOCUS_RULE" ] && printf '%s\n' "$PAGE_FOOTER_FOCUS_RULE" | grep -qF 'outline: 2px solid var(--color-accent);'; then
  echo "  [ok] page footer focus-visible"
else
  fail "styles.css is missing the page footer focus-visible outline: 2px solid var(--color-accent);"
fi

echo "Serving command: python3 -m http.server 3201 --directory ."
echo "Manual verification: open http://localhost:3201 in a mobile viewport (320/375/768px)."

if [ "${RUN_SERVE_COMMAND:-0}" = "1" ]; then
  exec python3 -m http.server 3201 --directory .
fi
