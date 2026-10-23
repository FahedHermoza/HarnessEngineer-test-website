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

echo "Avatar fallback checks:"

PROFILE_BLOCK=$(awk '
  /<header class="profile">/ { in_profile = 1 }
  in_profile { print }
  in_profile && /<\/header>/ { exit }
' index.html)

AVATAR_FALLBACK_MARKUP=(
  'class="profile-avatar-frame"'
  'class="profile-avatar-fallback"'
  '>FH</span>'
  'aria-hidden="true"'
  "onerror=\"this.parentElement.classList.add('profile-avatar-frame--fallback')\""
)

fallback_markup_missing=0
for entry in "${AVATAR_FALLBACK_MARKUP[@]}"; do
  case "$PROFILE_BLOCK" in
    *"$entry"*)
      ;;
    *)
      echo "FAILED - .profile markup missing avatar fallback element: $entry" >&2
      fallback_markup_missing=$((fallback_markup_missing + 1))
      ;;
  esac
done

if [ "$fallback_markup_missing" -gt 0 ]; then
  fail "avatar fallback markup is missing $fallback_markup_missing of 5 required elements"
fi
echo "  [ok] avatar fallback markup"

PROFILE_AVATAR_FRAME_RULE=$(awk '
  /^[[:space:]]*\.profile-avatar-frame[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$PROFILE_AVATAR_FRAME_RULE" ]; then
  fail "styles.css is missing the .profile-avatar-frame base rule"
fi
echo "  [ok] .profile-avatar-frame rule exists"

PROFILE_AVATAR_FRAME_CONTRACT=(
  'display: grid;'
  'width: 88px;'
  'height: 88px;'
)

frame_total=${#PROFILE_AVATAR_FRAME_CONTRACT[@]}
frame_present=0
frame_missing=0
for declaration in "${PROFILE_AVATAR_FRAME_CONTRACT[@]}"; do
  case "$PROFILE_AVATAR_FRAME_RULE" in
    *"$declaration"*)
      frame_present=$((frame_present + 1))
      ;;
    *)
      echo "FAILED - .profile-avatar-frame base rule missing declaration: $declaration" >&2
      frame_missing=$((frame_missing + 1))
      ;;
  esac
done

if [ "$frame_missing" -gt 0 ]; then
  fail "profile avatar frame contract is missing $frame_missing of $frame_total required declarations"
fi

echo "  [ok] profile avatar frame contract ($frame_present/$frame_total)"

PROFILE_AVATAR_STACK_RULE=$(awk '
  /^[[:space:]]*\.profile-avatar-frame > \*[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$PROFILE_AVATAR_STACK_RULE" ] && printf '%s\n' "$PROFILE_AVATAR_STACK_RULE" | grep -qF 'grid-area: 1 / 1;'; then
  echo "  [ok] avatar fallback stacking"
else
  fail "styles.css is missing the avatar fallback stacking rule grid-area: 1 / 1;"
fi

PROFILE_AVATAR_FALLBACK_RULE=$(awk '
  /^[[:space:]]*\.profile-avatar-fallback[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$PROFILE_AVATAR_FALLBACK_RULE" ]; then
  fail "styles.css is missing the .profile-avatar-fallback base rule"
fi
echo "  [ok] .profile-avatar-fallback rule exists"

PROFILE_AVATAR_FALLBACK_CONTRACT=(
  'display: none;'
  'width: 88px;'
  'height: 88px;'
  'border-radius: var(--radius-full);'
  'background-color: var(--color-surface-container-low);'
  'color: var(--color-primary);'
  'box-shadow: 0 0 0 3px var(--color-surface);'
  'font-size: var(--text-headline-lg-font-size);'
  'font-weight: var(--text-headline-lg-font-weight);'
  'line-height: var(--text-headline-lg-line-height);'
)

fallback_total=${#PROFILE_AVATAR_FALLBACK_CONTRACT[@]}
fallback_present=0
fallback_missing=0
for declaration in "${PROFILE_AVATAR_FALLBACK_CONTRACT[@]}"; do
  case "$PROFILE_AVATAR_FALLBACK_RULE" in
    *"$declaration"*)
      fallback_present=$((fallback_present + 1))
      ;;
    *)
      echo "FAILED - .profile-avatar-fallback base rule missing declaration: $declaration" >&2
      fallback_missing=$((fallback_missing + 1))
      ;;
  esac
done

if [ "$fallback_missing" -gt 0 ]; then
  fail "avatar fallback contract is missing $fallback_missing of $fallback_total required declarations"
fi

echo "  [ok] avatar fallback contract ($fallback_present/$fallback_total)"

PROFILE_AVATAR_FALLBACK_IMAGE_RULE=$(awk '
  /^[[:space:]]*\.profile-avatar-frame--fallback \.profile-avatar[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

PROFILE_AVATAR_FALLBACK_ACTIVE_RULE=$(awk '
  /^[[:space:]]*\.profile-avatar-frame--fallback \.profile-avatar-fallback[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$PROFILE_AVATAR_FALLBACK_IMAGE_RULE" ] \
  && printf '%s\n' "$PROFILE_AVATAR_FALLBACK_IMAGE_RULE" | grep -qF 'opacity: 0;' \
  && [ -n "$PROFILE_AVATAR_FALLBACK_ACTIVE_RULE" ] \
  && printf '%s\n' "$PROFILE_AVATAR_FALLBACK_ACTIVE_RULE" | grep -qF 'display: flex;'; then
  echo "  [ok] avatar fallback activation"
else
  fail "styles.css is missing the avatar fallback activation rules (opacity: 0; and display: flex;)"
fi

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

echo "Link checks:"

if grep -qF 'class="links"' index.html \
  && grep -qE 'class="link-button[^"]*"' index.html \
  && grep -qF '<span class="link-button__label">Celular</span>' index.html; then
  echo "  [ok] celular link markup"
else
  fail "index.html is missing the Celular link markup"
fi

if grep -qF 'href="tel:+51955116562"' index.html; then
  echo "  [ok] celular link destination"
else
  fail "index.html is missing the Celular link destination tel:+51955116562"
fi

if grep -qF 'aria-label="Celular: llamar al +51 955 116 562"' index.html; then
  echo "  [ok] celular link accessible label"
else
  fail "index.html is missing the Celular link accessible label"
fi

LINKS_RULE=$(awk '
  /^[[:space:]]*\.links[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$LINKS_RULE" ]; then
  fail "styles.css is missing the .links base rule"
fi
echo "  [ok] .links base rule exists"

LINKS_CONTRACT=(
  'padding: 0 var(--space-lg);'
)

links_total=${#LINKS_CONTRACT[@]}
links_present=0
links_missing=0
for declaration in "${LINKS_CONTRACT[@]}"; do
  case "$LINKS_RULE" in
    *"$declaration"*)
      links_present=$((links_present + 1))
      ;;
    *)
      echo "FAILED - .links base rule missing declaration: $declaration" >&2
      links_missing=$((links_missing + 1))
      ;;
  esac
done

if [ "$links_missing" -gt 0 ]; then
  echo "Harness status: FAILED - links container contract is missing $links_missing of $links_total required declarations" >&2
  exit 1
fi

echo "  [ok] links container contract ($links_present/$links_total)"

echo "Profile identity checks:"

if grep -qF 'class="profile-identity"' index.html; then
  echo "  [ok] profile identity markup"
else
  fail "index.html is missing class=\"profile-identity\""
fi

if grep -qF '<h1 class="profile-identity__name">Fahed Hermoza</h1>' index.html; then
  echo "  [ok] profile name heading"
else
  fail "index.html is missing the profile name heading"
fi

PROFILE_IDENTITY_TEXTS=(
  '>Fahed Hermoza<'
  '>@fahedhermoza<'
  '>Software Engineer &amp; Speaker &amp; Builder<'
)
for text in "${PROFILE_IDENTITY_TEXTS[@]}"; do
  if grep -qF -- "$text" index.html; then
    echo "  [ok] profile identity text: $text"
  else
    fail "index.html is missing profile identity text: $text"
  fi
done

PROFILE_IDENTITY_RULE=$(awk '
  /^[[:space:]]*\.profile-identity[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

PROFILE_IDENTITY_NAME_RULE=$(awk '
  /^[[:space:]]*\.profile-identity__name[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

PROFILE_IDENTITY_HANDLE_RULE=$(awk '
  /^[[:space:]]*\.profile-identity__handle[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

PROFILE_IDENTITY_TAGLINE_RULE=$(awk '
  /^[[:space:]]*\.profile-identity__tagline[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

PROFILE_IDENTITY_RULES=(
  ".profile-identity:$PROFILE_IDENTITY_RULE"
  ".profile-identity__name:$PROFILE_IDENTITY_NAME_RULE"
  ".profile-identity__handle:$PROFILE_IDENTITY_HANDLE_RULE"
  ".profile-identity__tagline:$PROFILE_IDENTITY_TAGLINE_RULE"
)
for entry in "${PROFILE_IDENTITY_RULES[@]}"; do
  selector=${entry%%:*}
  rule=${entry#*:}
  if [ -z "$rule" ]; then
    fail "styles.css is missing the $selector rule"
  fi
  echo "  [ok] $selector rule exists"
done

check_profile_rule_contract() {
  local selector="$1"
  local rule="$2"
  shift 2
  local total=$#
  local present=0
  local missing=0
  local declaration

  for declaration in "$@"; do
    case "$rule" in
      *"$declaration"*)
        present=$((present + 1))
        ;;
      *)
        echo "FAILED - $selector rule missing declaration: $declaration" >&2
        missing=$((missing + 1))
        ;;
    esac
  done

  if [ "$missing" -gt 0 ]; then
    fail "$selector contract is missing $missing of $total required declarations"
  fi

  echo "  [ok] $selector contract ($present/$total)"
}

check_profile_rule_contract ".profile-identity" "$PROFILE_IDENTITY_RULE" \
  'padding: var(--space-xl) var(--space-lg);' \
  'text-align: center;'

check_profile_rule_contract ".profile-identity__name" "$PROFILE_IDENTITY_NAME_RULE" \
  'font-size: var(--text-headline-lg-font-size);' \
  'font-weight: var(--text-headline-lg-font-weight);' \
  'line-height: var(--text-headline-lg-line-height);' \
  'letter-spacing: var(--text-headline-lg-letter-spacing);' \
  'color: var(--color-on-surface);'

check_profile_rule_contract ".profile-identity__handle" "$PROFILE_IDENTITY_HANDLE_RULE" \
  'font-size: var(--text-headline-lg-font-size);' \
  'font-weight: var(--text-headline-lg-font-weight);' \
  'line-height: var(--text-headline-lg-line-height);' \
  'letter-spacing: var(--text-headline-lg-letter-spacing);' \
  'color: var(--color-on-surface-variant);'

check_profile_rule_contract ".profile-identity__tagline" "$PROFILE_IDENTITY_TAGLINE_RULE" \
  'font-size: var(--text-body-md-font-size);' \
  'font-weight: var(--text-body-md-font-weight);' \
  'line-height: var(--text-body-md-line-height);' \
  'color: var(--color-on-surface-variant);'

case "$PROFILE_IDENTITY_TAGLINE_RULE" in
  *letter-spacing*)
    fail ".profile-identity__tagline must not declare letter-spacing"
    ;;
  *)
    echo "  [ok] .profile-identity__tagline omits letter-spacing"
    ;;
esac

echo "Link checks:"

if grep -qF '<nav class="links" aria-label="Enlaces de contacto">' index.html; then
  echo "  [ok] links container"
else
  fail 'index.html is missing the links container (<nav class="links" aria-label="Enlaces de contacto">)'
fi

LINKS_BLOCK=$(awk '
  /<nav class="links"/ { in_nav = 1 }
  in_nav { print }
  in_nav && /<\/nav>/ { exit }
' index.html)

if printf '%s\n' "$LINKS_BLOCK" | grep -qF 'href="https://www.facebook.com/fahed19"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'class="link-button link-button--gradient-2"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF '<span class="link-button__label">Facebook</span>' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'aria-label="Facebook de Fahed Hermoza"'; then
  echo "  [ok] facebook link markup"
else
  fail "index.html is missing the Facebook link markup (href, .link-button--gradient-2, visible label or accessible name)"
fi

if printf '%s\n' "$LINKS_BLOCK" | grep -qF 'class="link-button__icon"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'fill="currentColor"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'aria-hidden="true"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'focusable="false"'; then
  echo "  [ok] facebook link icon"
else
  fail "index.html is missing the decorative Facebook icon (currentColor, aria-hidden or focusable)"
fi

LINKS_RULE=$(awk '
  /^[[:space:]]*\.links[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$LINKS_RULE" ] && printf '%s\n' "$LINKS_RULE" | grep -qF 'padding: 0 var(--space-lg);'; then
  echo "  [ok] links container padding"
else
  fail "styles.css is missing the links container padding: 0 var(--space-lg);"
fi

if [ -n "$LINKS_RULE" ] \
  && printf '%s\n' "$LINKS_RULE" | grep -qF 'gap: var(--space-sm);' \
  && printf '%s\n' "$LINKS_RULE" | grep -qF 'flex-direction: column;'; then
  echo "  [ok] links container gap"
else
  fail "styles.css is missing the links container gap: var(--space-sm); with flex-direction: column;"
fi

echo "Portfolio link checks:"

if printf '%s\n' "$LINKS_BLOCK" | grep -qF 'href="https://fahedhermoza.github.io/"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF '>Portafolio<'; then
  echo "  [ok] portfolio link markup"
else
  fail "index.html is missing the portfolio link markup (href or Portafolio label)"
fi

PORTFOLIO_ANCHOR=$(awk '
  /href="https:\/\/fahedhermoza\.github\.io\/"/ { in_anchor = 1 }
  in_anchor { print }
  in_anchor && /<\/a>/ { exit }
' index.html)

if [ -z "$PORTFOLIO_ANCHOR" ]; then
  fail "index.html is missing the portfolio anchor block"
fi

if printf '%s\n' "$PORTFOLIO_ANCHOR" | grep -qF 'class="link-button__icon"' \
  && printf '%s\n' "$PORTFOLIO_ANCHOR" | grep -qF 'aria-hidden="true"' \
  && printf '%s\n' "$PORTFOLIO_ANCHOR" | grep -qF 'focusable="false"' \
  && printf '%s\n' "$PORTFOLIO_ANCHOR" | grep -qF '<path d="M9 18l6-6-6-6"/>'; then
  echo "  [ok] portfolio link icon"
else
  fail "index.html is missing the decorative portfolio link icon"
fi

echo "LinkedIn link checks:"

if printf '%s\n' "$LINKS_BLOCK" | grep -qE '<a[^>]*class="link-button[^"]*"[^>]*href="https://www\.linkedin\.com/in/fahedhermoza/"'; then
  echo "  [ok] LinkedIn link destination"
else
  fail "index.html is missing the LinkedIn link destination https://www.linkedin.com/in/fahedhermoza/"
fi

LINKEDIN_LINK_BLOCK=$(awk '
  /<a[^>]*href="https:\/\/www\.linkedin\.com\/in\/fahedhermoza\/"/ { in_link = 1 }
  in_link { print }
  in_link && /<\/a>/ { exit }
' index.html)

if printf '%s\n' "$LINKEDIN_LINK_BLOCK" | grep -qF '>LinkedIn<'; then
  echo "  [ok] LinkedIn link label"
else
  fail "LinkedIn link is missing its visible label >LinkedIn<"
fi

if printf '%s\n' "$LINKEDIN_LINK_BLOCK" | grep -qF 'aria-hidden="true"' \
  && printf '%s\n' "$LINKEDIN_LINK_BLOCK" | grep -qF 'focusable="false"'; then
  echo "  [ok] LinkedIn icon is decorative"
else
  fail "LinkedIn icon must declare aria-hidden=\"true\" and focusable=\"false\""
fi

echo "Link Correo checks:"

LINK_CORREO_ANCHOR=$(awk '
  /<a[^>]*href="mailto:fahedhermoza@gmail\.com"/ { in_anchor = 1 }
  in_anchor { print }
  in_anchor && /<\/a>/ { exit }
' index.html)

if [ -z "$LINK_CORREO_ANCHOR" ]; then
  fail "index.html is missing the link Correo anchor"
fi

LINK_CORREO_CONTRACT=(
  'class="link-button link-button--gradient-4-5"'
  'href="mailto:fahedhermoza@gmail.com"'
  'aria-label="Correo a fahedhermoza@gmail.com"'
  '<span class="link-button__label">Correo</span>'
  'class="link-button__icon"'
  'aria-hidden="true"'
  'focusable="false"'
)

correo_total=${#LINK_CORREO_CONTRACT[@]}
correo_present=0
correo_missing=0
for entry in "${LINK_CORREO_CONTRACT[@]}"; do
  case "$LINK_CORREO_ANCHOR" in
    *"$entry"*)
      correo_present=$((correo_present + 1))
      ;;
    *)
      echo "FAILED - link Correo anchor missing: $entry" >&2
      correo_missing=$((correo_missing + 1))
      ;;
  esac
done

if [ "$correo_missing" -gt 0 ]; then
  echo "Harness status: FAILED - link Correo contract is missing $correo_missing of $correo_total required items" >&2
  exit 1
fi

echo "  [ok] link Correo contract ($correo_present/$correo_total)"

echo "Sharing metadata checks:"

SHARING_METADATA_CONTRACT=(
  'og:title|<meta property="og:title" content="[^"]+"'
  'og:description|<meta property="og:description" content="[^"]+"'
  'og:type|<meta property="og:type" content="profile"'
  'og:site_name|<meta property="og:site_name" content="[^"]+"'
  'og:image|<meta property="og:image" content="([^"]*/)?assets/og-image\.jpg"'
  'og:image:type|<meta property="og:image:type" content="image/jpeg"'
  'og:image:width|<meta property="og:image:width" content="1200"'
  'og:image:height|<meta property="og:image:height" content="630"'
  'og:image:alt|<meta property="og:image:alt" content="[^"]+"'
  'twitter:card|<meta name="twitter:card" content="summary_large_image"'
  'twitter:title|<meta name="twitter:title" content="[^"]+"'
  'twitter:description|<meta name="twitter:description" content="[^"]+"'
  'twitter:image|<meta name="twitter:image" content="([^"]*/)?assets/og-image\.jpg"'
  'twitter:image:alt|<meta name="twitter:image:alt" content="[^"]+"'
)

sharing_total=${#SHARING_METADATA_CONTRACT[@]}
sharing_present=0
sharing_missing=0
for entry in "${SHARING_METADATA_CONTRACT[@]}"; do
  sharing_key="${entry%%|*}"
  sharing_pattern="${entry#*|}"
  if grep -qE -- "$sharing_pattern" index.html; then
    sharing_present=$((sharing_present + 1))
  else
    echo "FAILED - index.html is missing sharing metadata tag: $sharing_key" >&2
    sharing_missing=$((sharing_missing + 1))
  fi
done

if [ "$sharing_missing" -gt 0 ]; then
  echo "Harness status: FAILED - sharing metadata contract is missing $sharing_missing of $sharing_total required tags" >&2
  exit 1
fi

echo "  [ok] sharing metadata contract ($sharing_present/$sharing_total)"

if [ -f "assets/og-image.jpg" ]; then
  echo "  [ok] assets/og-image.jpg exists"
else
  echo "  [warn] assets/og-image.jpg is missing (link preview image blocker; produce it with an external tool)"
fi

if grep -qE '<meta property="og:image" content="https?://' index.html && grep -qE '<meta name="twitter:image" content="https?://' index.html; then
  echo "  [ok] og:image/twitter:image use an absolute path"
else
  echo "  [warn] og:image/twitter:image use a relative path (must be absolute after deploy)"
fi

if grep -q 'property="og:url"' index.html && grep -q 'rel="canonical"' index.html; then
  echo "  [ok] og:url and canonical declared"
else
  echo "  [warn] og:url/canonical pending public URL (deploy-cloudflare-pages)"
fi

echo "Instagram link checks:"

LINKS_BLOCK=$(awk '
  /<nav class="links"/ { in_nav = 1 }
  in_nav { print }
  in_nav && /<\/nav>/ { exit }
' index.html)

if [ -z "$LINKS_BLOCK" ]; then
  fail "index.html is missing the links navigation block (<nav class=\"links\">)"
fi
echo "  [ok] links navigation block exists"

if printf '%s\n' "$LINKS_BLOCK" | grep -qF 'aria-label="Enlaces de contacto"'; then
  echo "  [ok] links navigation label"
else
  fail "index.html is missing the links navigation label Enlaces de contacto"
fi

INSTAGRAM_LINK_BLOCK=$(awk '
  /href="https:\/\/www\.instagram\.com\/fahedhermoza\/"/ { in_link = 1 }
  in_link { print }
  in_link && /<\/a>/ { exit }
' index.html)

case "$INSTAGRAM_LINK_BLOCK" in
  *'class="link-button link-button--gradient-1"'*)
    echo "  [ok] Instagram Enlace uses gradient-1"
    ;;
  *)
    fail "the Instagram Enlace must use class=\"link-button link-button--gradient-1\""
    ;;
esac

if printf '%s\n' "$INSTAGRAM_LINK_BLOCK" | grep -qE 'class="link-button[^"]*"'; then
  echo "  [ok] Instagram Enlace markup"
else
  fail "index.html is missing the Instagram Enlace markup"
fi

if printf '%s\n' "$LINKS_BLOCK" | grep -qF 'href="https://www.instagram.com/fahedhermoza/"'; then
  echo "  [ok] Instagram Enlace destination https://www.instagram.com/fahedhermoza/"
else
  fail "index.html is missing the Instagram Enlace destination https://www.instagram.com/fahedhermoza/"
fi

if printf '%s\n' "$LINKS_BLOCK" | grep -qF '>Instagram<'; then
  echo "  [ok] Instagram Enlace label"
else
  fail "index.html is missing the Instagram Enlace label >Instagram<"
fi

ICON_CONTRACT=(
  'class="link-button__icon"'
  'width="18"'
  'height="18"'
  'stroke="currentColor"'
  'aria-hidden="true"'
  'focusable="false"'
)

icon_total=${#ICON_CONTRACT[@]}
icon_present=0
icon_missing=0
for attribute in "${ICON_CONTRACT[@]}"; do
  case "$LINKS_BLOCK" in
    *"$attribute"*)
      icon_present=$((icon_present + 1))
      ;;
    *)
      echo "FAILED - Instagram Enlace icon missing attribute: $attribute" >&2
      icon_missing=$((icon_missing + 1))
      ;;
  esac
done

if [ "$icon_missing" -gt 0 ]; then
  echo "Harness status: FAILED - Instagram Enlace icon contract is missing $icon_missing of $icon_total required attributes" >&2
  exit 1
fi

echo "  [ok] Instagram Enlace icon contract ($icon_present/$icon_total)"

LINKS_RULE=$(awk '
  /^[[:space:]]*\.links[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$LINKS_RULE" ]; then
  fail "styles.css is missing the .links layout rule"
fi

case "$LINKS_RULE" in
  *'padding: 0 var(--space-lg);'*)
    echo "  [ok] .links layout rule"
    ;;
  *)
    fail "styles.css .links layout rule is missing declaration: padding: 0 var(--space-lg);"
    ;;
esac

if grep -qF 'data-demo="link-button"' index.html; then
  fail "index.html still contains the temporary link button demo [data-demo=\"link-button\"]"
fi

LINK_DEMO_LABELS=(
  '>Enlace uno<'
  '>Enlace dos<'
  '>Enlace tres<'
  '>Enlace cuatro<'
  '>Enlace cinco<'
)
for label in "${LINK_DEMO_LABELS[@]}"; do
  if grep -qF -- "$label" index.html; then
    fail "index.html still contains the temporary link button demo label: $label"
  fi
done
echo "  [ok] link button demo removed"

echo "WhatsApp link checks:"

if printf '%s\n' "$LINKS_BLOCK" | grep -qF 'href="https://wa.me/51955116562"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF '>WhatsApp<' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'aria-label="WhatsApp"'; then
  echo "  [ok] WhatsApp Enlace markup"
else
  fail "index.html is missing the WhatsApp Enlace markup (href, label or aria-label)"
fi

WHATSAPP_ANCHOR=$(awk '
  /href="https:\/\/wa\.me\/51955116562"/ { in_anchor = 1 }
  in_anchor { print }
  in_anchor && /<\/a>/ { exit }
' index.html)

if [ -z "$WHATSAPP_ANCHOR" ]; then
  fail "index.html is missing the WhatsApp anchor block"
fi

WHATSAPP_ICON_CONTRACT=(
  'class="link-button__icon"'
  'width="18"'
  'height="18"'
  'fill="currentColor"'
  'aria-hidden="true"'
  'focusable="false"'
)

whatsapp_icon_total=${#WHATSAPP_ICON_CONTRACT[@]}
whatsapp_icon_present=0
whatsapp_icon_missing=0
for attribute in "${WHATSAPP_ICON_CONTRACT[@]}"; do
  case "$WHATSAPP_ANCHOR" in
    *"$attribute"*)
      whatsapp_icon_present=$((whatsapp_icon_present + 1))
      ;;
    *)
      echo "FAILED - WhatsApp link icon is missing attribute: $attribute" >&2
      whatsapp_icon_missing=$((whatsapp_icon_missing + 1))
      ;;
  esac
done

if [ "$whatsapp_icon_missing" -gt 0 ]; then
  echo "Harness status: FAILED - whatsapp icon contract is missing $whatsapp_icon_missing of $whatsapp_icon_total required attributes" >&2
  exit 1
fi

echo "  [ok] whatsapp icon contract ($whatsapp_icon_present/$whatsapp_icon_total)"

echo "Order and gradient checks:"

LINK_ANCHOR_COUNT=$(printf '%s\n' "$LINKS_BLOCK" | grep -oE '<a[[:space:]]' | wc -l | tr -d '[:space:]')
if [ "$LINK_ANCHOR_COUNT" -eq 7 ]; then
  echo "  [ok] links anchors (7/7)"
else
  fail "the links navigation must contain exactly 7 anchors; found $LINK_ANCHOR_COUNT"
fi

LINK_LABELS=$(printf '%s\n' "$LINKS_BLOCK" \
  | grep -oE '<span class="link-button__label">[^<]+</span>' \
  | sed -E 's/^.*>([^<]+)<.*$/\1/' | paste -sd '|' -) || true
EXPECTED_LINK_LABELS='Instagram|Facebook|WhatsApp|LinkedIn|Portafolio|Correo|Celular'
if [ "$LINK_LABELS" = "$EXPECTED_LINK_LABELS" ]; then
  echo "  [ok] links order (7/7)"
else
  fail "links order mismatch: expected $EXPECTED_LINK_LABELS, found ${LINK_LABELS:-<none>}"
fi

LINK_CLASSES=$(printf '%s\n' "$LINKS_BLOCK" \
  | grep -oE '<a[^>]*class="link-button[^"]*"' \
  | sed -E 's/^.*class="([^"]+)".*$/\1/' | paste -sd '|' -) || true
EXPECTED_LINK_CLASSES='link-button link-button--gradient-1|link-button link-button--gradient-2|link-button link-button--gradient-3|link-button link-button--gradient-3-4|link-button link-button--gradient-4|link-button link-button--gradient-4-5|link-button link-button--gradient-5'
if [ "$LINK_CLASSES" = "$EXPECTED_LINK_CLASSES" ]; then
  echo "  [ok] links tone progression (7/7)"
else
  fail "links tone progression mismatch: expected $EXPECTED_LINK_CLASSES, found ${LINK_CLASSES:-<none>}"
fi

LINK_INTERPOLATION_RULES=(
  'color-mix(in srgb, var(--color-gradient-3), var(--color-gradient-4))'
  'color-mix(in srgb, var(--color-gradient-4), var(--color-gradient-5))'
)
interpolation_total=${#LINK_INTERPOLATION_RULES[@]}
interpolation_present=0
interpolation_missing=0
for expression in "${LINK_INTERPOLATION_RULES[@]}"; do
  if grep -qF -- "$expression" styles.css; then
    interpolation_present=$((interpolation_present + 1))
  else
    echo "FAILED - styles.css missing interpolated tone expression: $expression" >&2
    interpolation_missing=$((interpolation_missing + 1))
  fi
done
if [ "$interpolation_missing" -gt 0 ]; then
  fail "interpolated tone rules are missing $interpolation_missing of $interpolation_total required expressions"
fi
echo "  [ok] interpolated tone rules ($interpolation_present/$interpolation_total)"

if grep -qF '@supports (color: color-mix(in srgb, red, blue))' styles.css; then
  echo "  [ok] color-mix support guard"
else
  fail "styles.css is missing the @supports (color: color-mix(in srgb, red, blue)) guard"
fi

if grep -qF 'data-demo="link-button"' index.html || grep -qF 'data-demo="link-button"' styles.css; then
  fail "temporary link button demo marker [data-demo=\"link-button\"] is still present"
fi

if grep -qF '#link-button-demo' index.html || grep -qF '#link-button-demo' styles.css; then
  fail "temporary link button demo id #link-button-demo is still present"
fi

for label in "${LINK_DEMO_LABELS[@]}"; do
  if grep -qF -- "$label" index.html; then
    fail "temporary link button demo label is still present: $label"
  fi
done
echo "  [ok] link button demo removed (HTML and CSS)"

echo "Save contact checks:"

VCF_FILE="assets/fahedhermoza.vcf"

if [ ! -f "$VCF_FILE" ] || [ ! -s "$VCF_FILE" ]; then
  fail "assets/fahedhermoza.vcf is missing or empty"
fi

VCF_SIZE=$(wc -c < "$VCF_FILE" | tr -d ' ')
if [ "$VCF_SIZE" -gt 4096 ]; then
  fail "assets/fahedhermoza.vcf must be at most 4096 bytes (found $VCF_SIZE)"
fi

if ! python3 - "$VCF_FILE" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])

def bad(message):
    print(f"FAILED - assets/fahedhermoza.vcf {message}", file=sys.stderr)
    sys.exit(1)

data = path.read_bytes()
if data.startswith(b"\xef\xbb\xbf"):
    bad("must not start with a UTF-8 BOM")
try:
    text = data.decode("utf-8")
except UnicodeDecodeError:
    bad("must be valid UTF-8")

without_crlf = text.replace("\r\n", "")
if "\r" in without_crlf or "\n" in without_crlf:
    bad("must use CRLF line endings only")
if not text.endswith("\r\n"):
    bad("must end with CRLF after END:VCARD")

expected = [
    "BEGIN:VCARD",
    "VERSION:3.0",
    "N:Hermoza;Fahed;;;",
    "FN:Fahed Hermoza",
    "TITLE:Software Engineer & Speaker & Builder",
    "TEL;TYPE=CELL:+51955116562",
    "EMAIL;TYPE=INTERNET:fahedhermoza@gmail.com",
    "URL:https://www.instagram.com/fahedhermoza/",
    "URL:https://www.facebook.com/fahed19",
    "URL:https://wa.me/51955116562",
    "URL:https://www.linkedin.com/in/fahedhermoza/",
    "URL:https://fahedhermoza.github.io/",
    "END:VCARD",
]
lines = text.split("\r\n")[:-1]
for line in expected:
    if line not in lines:
        bad(f"is missing canonical line: {line}")
if lines != expected:
    bad("must contain the canonical VCARD 3.0 lines in the exact order")
if len([line for line in lines if line.startswith("URL:")]) != 5:
    bad("must contain exactly five URL lines")
PY
then
  echo "Harness status: FAILED - assets/fahedhermoza.vcf failed the vCard contract" >&2
  exit 1
fi
echo "  [ok] vCard asset contract (UTF-8, CRLF, VCARD 3.0, canonical fields, ${VCF_SIZE} bytes)"

for url in \
  "https://www.instagram.com/fahedhermoza/" \
  "https://www.facebook.com/fahed19" \
  "https://wa.me/51955116562" \
  "https://www.linkedin.com/in/fahedhermoza/" \
  "https://fahedhermoza.github.io/"
do
  if grep -qF "URL:$url" "$VCF_FILE" && grep -qF "href=\"$url\"" index.html; then
    :
  else
    fail "vCard URL does not match an index.html href: $url"
  fi
done

if ! grep -qF 'TEL;TYPE=CELL:+51955116562' "$VCF_FILE" \
  || ! grep -qF 'href="tel:+51955116562"' index.html \
  || ! grep -qF '>Celular<' index.html; then
  fail "vCard TEL does not match the Celular control"
fi

if ! grep -qF 'EMAIL;TYPE=INTERNET:fahedhermoza@gmail.com' "$VCF_FILE" \
  || ! grep -qF 'href="mailto:fahedhermoza@gmail.com"' index.html \
  || ! grep -qF '>Correo<' index.html; then
  fail "vCard EMAIL does not match the Correo control"
fi
echo "  [ok] vCard URLs, phone and email match the page controls"

save_contact_wrappers=$(grep -oF 'class="save-contact"' index.html | wc -l | tr -d ' ')
if [ "$save_contact_wrappers" -ne 1 ]; then
  fail "index.html must contain exactly one .save-contact block (found $save_contact_wrappers)"
fi

save_contact_anchors=$(grep -oE '<a[^>]*class="save-contact-button"' index.html | wc -l | tr -d ' ')
if [ "$save_contact_anchors" -ne 1 ]; then
  fail "index.html must contain exactly one .save-contact-button anchor (found $save_contact_anchors)"
fi

SAVE_CONTACT_BLOCK=$(awk '
  /^[[:space:]]*<div class="save-contact">/ { in_block = 1 }
  in_block { print }
  in_block && /^[[:space:]]*<\/div>[[:space:]]*$/ { exit }
' index.html)

if [ -z "$SAVE_CONTACT_BLOCK" ]; then
  fail "index.html is missing the .save-contact block"
fi

if ! printf '%s\n' "$SAVE_CONTACT_BLOCK" | grep -qF '<a class="save-contact-button" href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">'; then
  fail 'index.html .save-contact-button must use href="assets/fahedhermoza.vcf" and download="fahedhermoza.vcf"'
fi

if ! printf '%s\n' "$SAVE_CONTACT_BLOCK" | grep -qF '>Guardar contacto<'; then
  fail 'index.html .save-contact-button must have the "Guardar contacto" label'
fi

SAVE_CONTACT_ICON_TAG=$(printf '%s\n' "$SAVE_CONTACT_BLOCK" | grep -oE '<svg[^>]*class="save-contact-button__icon"[^>]*>' | head -n 1 || true)
if [ -z "$SAVE_CONTACT_ICON_TAG" ]; then
  fail "index.html .save-contact-button is missing its icon"
fi
for attribute in 'width="18"' 'height="18"' 'aria-hidden="true"' 'focusable="false"'; do
  case "$SAVE_CONTACT_ICON_TAG" in
    *"$attribute"*)
      ;;
    *)
      echo "FAILED - .save-contact-button icon is missing $attribute" >&2
      fail "save contact icon contract is incomplete"
      ;;
  esac
done

block_anchor_total=$(printf '%s\n' "$SAVE_CONTACT_BLOCK" | grep -cE '<a[[:space:]]' || true)
if [ "$block_anchor_total" -ne 1 ]; then
  fail "index.html .save-contact block must contain exactly one anchor (found $block_anchor_total)"
fi

if grep -qE 'data:text/vcard|<script|new Blob' index.html styles.css; then
  fail "the save contact control must not use data:text/vcard, <script> or Blob"
fi
echo "  [ok] save contact markup, label, icon and static href/download"

nav_close_line=$(grep -nF '</nav>' index.html | head -n 1 | cut -d: -f1 || true)
save_contact_line=$(grep -nF '<div class="save-contact">' index.html | head -n 1 | cut -d: -f1 || true)
footer_line=$(grep -nF '<footer class="page-footer">' index.html | head -n 1 | cut -d: -f1 || true)

if [ -z "$nav_close_line" ] || [ -z "$save_contact_line" ] || [ -z "$footer_line" ]; then
  fail "index.html is missing </nav>, .save-contact or <footer class=\"page-footer\">"
fi
if [ "$nav_close_line" -ge "$save_contact_line" ] || [ "$save_contact_line" -ge "$footer_line" ]; then
  fail 'index.html .save-contact must sit after </nav> and before <footer class="page-footer">'
fi
echo "  [ok] save contact sits between the links navigation and the page footer"

SAVE_CONTACT_LAYOUT_RULE=$(awk '
  /^[[:space:]]*\.save-contact[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$SAVE_CONTACT_LAYOUT_RULE" ]; then
  fail "styles.css is missing the .save-contact layout rule"
fi
if printf '%s\n' "$SAVE_CONTACT_LAYOUT_RULE" | grep -qF 'padding: var(--space-sm) var(--space-lg) 0;'; then
  echo "  [ok] .save-contact layout rule"
else
  fail "styles.css .save-contact must declare padding: var(--space-sm) var(--space-lg) 0;"
fi

SAVE_CONTACT_RULE=$(awk '
  /^[[:space:]]*\.save-contact-button[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$SAVE_CONTACT_RULE" ]; then
  fail "styles.css is missing the .save-contact-button base rule"
fi
echo "  [ok] .save-contact-button base rule exists"

SAVE_CONTACT_CONTRACT=(
  'width: 100%;'
  'height: 48px;'
  'padding: 0 1.25rem;'
  'border-radius: var(--radius-md);'
  'justify-content: space-between;'
  'text-transform: uppercase;'
)

save_contact_contract_total=${#SAVE_CONTACT_CONTRACT[@]}
save_contact_contract_present=0
save_contact_contract_missing=0
for declaration in "${SAVE_CONTACT_CONTRACT[@]}"; do
  case "$SAVE_CONTACT_RULE" in
    *"$declaration"*)
      save_contact_contract_present=$((save_contact_contract_present + 1))
      ;;
    *)
      echo "FAILED - .save-contact-button base rule missing declaration: $declaration" >&2
      save_contact_contract_missing=$((save_contact_contract_missing + 1))
      ;;
  esac
done

if [ "$save_contact_contract_missing" -gt 0 ]; then
  fail "save contact button contract is missing $save_contact_contract_missing of $save_contact_contract_total required declarations"
fi
echo "  [ok] save contact button shape contract ($save_contact_contract_present/$save_contact_contract_total)"

if printf '%s\n' "$SAVE_CONTACT_RULE" | grep -qF 'background: var(--color-surface-container-low);' \
  && printf '%s\n' "$SAVE_CONTACT_RULE" | grep -qF 'color: var(--color-primary);'; then
  echo "  [ok] save contact neutral colors"
else
  fail 'styles.css .save-contact-button must use background: var(--color-surface-container-low); and color: var(--color-primary);'
fi

SAVE_CONTACT_FOCUS_RULE=$(awk '
  /^[[:space:]]*\.save-contact-button:focus-visible[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$SAVE_CONTACT_FOCUS_RULE" ] \
  && printf '%s\n' "$SAVE_CONTACT_FOCUS_RULE" | grep -qF 'outline: 2px solid var(--color-accent);' \
  && printf '%s\n' "$SAVE_CONTACT_FOCUS_RULE" | grep -qF 'outline-offset: 2px;'; then
  echo "  [ok] save contact focus-visible outline"
else
  fail 'styles.css .save-contact-button:focus-visible must declare outline: 2px solid var(--color-accent); and outline-offset: 2px;'
fi

SAVE_CONTACT_HOVER_RULE=$(awk '
  /^[[:space:]]*\.save-contact-button:hover[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$SAVE_CONTACT_HOVER_RULE" ] \
  && printf '%s\n' "$SAVE_CONTACT_HOVER_RULE" | grep -qF 'filter: brightness(1.03);' \
  && printf '%s\n' "$SAVE_CONTACT_FOCUS_RULE" | grep -qF 'filter: brightness(1.03);'; then
  echo "  [ok] save contact hover/focus brightness"
else
  fail 'styles.css .save-contact-button hover/focus must retain filter: brightness(1.03);'
fi

SAVE_CONTACT_REDUCED_BLOCK=$(awk '
  /@media \(prefers-reduced-motion: reduce\)/ { in_block = 1 }
  in_block { print }
  in_block && /^}/ { exit }
' styles.css)

if [ -n "$SAVE_CONTACT_REDUCED_BLOCK" ] \
  && printf '%s\n' "$SAVE_CONTACT_REDUCED_BLOCK" | grep -qF '.save-contact-button' \
  && printf '%s\n' "$SAVE_CONTACT_REDUCED_BLOCK" | grep -qF 'transition: none;' \
  && printf '%s\n' "$SAVE_CONTACT_REDUCED_BLOCK" | grep -qF 'transform: none;'; then
  echo "  [ok] save contact reduced motion"
else
  fail 'styles.css reduced-motion block must set transition: none; and transform: none; for .save-contact-button'
fi

echo "Accessibility checks:"

# 1. Document language and zoomable viewport
if grep -qF '<html lang="es">' index.html; then
  :
else
  fail 'index.html must declare <html lang="es">'
fi

VIEWPORT_TAG=$(grep -oE '<meta name="viewport" content="[^"]*"' index.html || true)
if [ -z "$VIEWPORT_TAG" ]; then
  fail "index.html is missing the viewport meta tag"
fi
if printf '%s\n' "$VIEWPORT_TAG" | grep -qF 'width=device-width'; then
  :
else
  fail "index.html viewport must declare width=device-width"
fi
if printf '%s\n' "$VIEWPORT_TAG" | grep -qE 'user-scalable[[:space:]]*=[[:space:]]*no|maximum-scale'; then
  fail "index.html must not disable zoom (user-scalable=no or maximum-scale)"
fi
echo "  [ok] accessible document language and zoomable viewport"

# 2. Language of parts and avatar alt
if grep -qF '<p class="profile-identity__tagline" lang="en">Software Engineer &amp; Speaker &amp; Builder</p>' index.html; then
  echo '  [ok] tagline language of parts (lang="en")'
else
  fail 'index.html tagline must declare lang="en" (WCAG 3.1.2)'
fi

AVATAR_TAG=$(awk '
  /<img/ { in_img = 1 }
  in_img { print }
  in_img && />/ { exit }
' index.html)

if printf '%s\n' "$AVATAR_TAG" | grep -qF 'class="profile-avatar"' \
  && printf '%s\n' "$AVATAR_TAG" | grep -qE 'alt="[^"]+"'; then
  echo "  [ok] avatar alt is descriptive and non-empty"
else
  fail "index.html profile avatar must keep a non-empty alt"
fi

# 3. Real controls: 10 anchors (7 link buttons + 1 save contact button + 2 footer links)
ANCHOR_TAGS=$(grep -oE '<a[[:space:]][^>]*>' index.html || true)
anchor_total=$(printf '%s\n' "$ANCHOR_TAGS" | grep -cE '<a[[:space:]]' || true)
link_button_total=$(grep -oE '<a[^>]*class="link-button( [^"]*)?"' index.html | wc -l | tr -d ' ')
footer_link_total=$(grep -oE '<a[^>]*class="page-footer__link"' index.html | wc -l | tr -d ' ')

if [ "$anchor_total" -ne 10 ]; then
  fail "index.html must contain exactly 10 anchor controls (found $anchor_total)"
fi
if [ "$link_button_total" -ne 7 ]; then
  fail "index.html must contain exactly 7 link-button anchors (found $link_button_total)"
fi
if [ "$save_contact_anchors" -ne 1 ]; then
  fail "index.html must contain exactly 1 save-contact-button anchor (found $save_contact_anchors)"
fi
if [ "$footer_link_total" -ne 2 ]; then
  fail "index.html must contain exactly 2 page-footer link anchors (found $footer_link_total)"
fi

link_button_class_total=$(grep -oE 'class="link-button( |")' index.html | wc -l | tr -d ' ')
save_contact_class_total=$(grep -oE 'class="save-contact-button( |")' index.html | wc -l | tr -d ' ')
footer_link_class_total=$(grep -oE 'class="page-footer__link( |")' index.html | wc -l | tr -d ' ')
if [ "$link_button_class_total" -ne "$link_button_total" ]; then
  fail "a non-anchor element uses class link-button (or an anchor duplicates the class)"
fi
if [ "$save_contact_class_total" -ne "$save_contact_anchors" ]; then
  fail "a non-anchor element uses class save-contact-button (or an anchor duplicates the class)"
fi
if [ "$footer_link_class_total" -ne "$footer_link_total" ]; then
  fail "a non-anchor element uses class page-footer__link (or an anchor duplicates the class)"
fi

missing_href=0
while IFS= read -r anchor; do
  [ -n "$anchor" ] || continue
  if printf '%s\n' "$anchor" | grep -qE '(^|[[:space:]])href="[^"]+"'; then
    :
  else
    echo "FAILED - anchor without a non-empty href: $anchor" >&2
    missing_href=$((missing_href + 1))
  fi
done <<< "$ANCHOR_TAGS"
if [ "$missing_href" -gt 0 ]; then
  fail "accessibility control contract is missing $missing_href of $anchor_total anchors with a non-empty href"
fi

if grep -qE 'role="button"' index.html; then
  fail 'index.html must not use role="button"; controls must be real anchors'
fi
if grep -qE 'on(click|keydown|keypress)[[:space:]]*=' index.html; then
  fail "index.html must not use inline event handlers for controls"
fi
if grep -qE '(^|[[:space:]])href="(#)?"' index.html; then
  fail 'index.html must not use href="#" or href=""'
fi
echo "  [ok] 10 real anchor controls (7 link buttons + 1 save contact button + 2 footer links)"

# 4. Decorative icons
SVG_TAGS=$(grep -oE '<svg[^>]*>' index.html || true)
svg_total=0
svg_bad=0
while IFS= read -r svg_tag; do
  [ -n "$svg_tag" ] || continue
  svg_total=$((svg_total + 1))
  case "$svg_tag" in
    *aria-hidden=\"true\"*)
      ;;
    *)
      echo "FAILED - SVG is missing aria-hidden=\"true\": $svg_tag" >&2
      svg_bad=$((svg_bad + 1))
      ;;
  esac
  case "$svg_tag" in
    *focusable=\"false\"*)
      ;;
    *)
      echo "FAILED - SVG is missing focusable=\"false\": $svg_tag" >&2
      svg_bad=$((svg_bad + 1))
      ;;
  esac
done <<< "$SVG_TAGS"

if [ "$svg_total" -ne 8 ]; then
  fail "index.html must contain exactly 8 decorative SVG icons (found $svg_total)"
fi
if [ "$svg_bad" -gt 0 ]; then
  fail "accessibility SVG contract is missing $svg_bad required attributes"
fi
if grep -qE '<span class="page-footer__separator"[^>]*aria-hidden="true"' index.html; then
  echo "  [ok] 8 decorative SVG icons and footer separator are hidden from assistive technology"
else
  fail 'the page footer separator must keep aria-hidden="true"'
fi

# 5. Visible focus
LINK_FOCUS_RULE=$(awk '
  /^[[:space:]]*\.link-button:focus-visible[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

FOOTER_FOCUS_RULE=$(awk '
  /^[[:space:]]*\.page-footer__link:focus-visible[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$LINK_FOCUS_RULE" ] \
  && printf '%s\n' "$LINK_FOCUS_RULE" | grep -qF 'outline: 2px solid var(--color-accent);' \
  && printf '%s\n' "$LINK_FOCUS_RULE" | grep -qF 'outline-offset: 2px;'; then
  :
else
  fail 'styles.css .link-button:focus-visible must declare outline: 2px solid var(--color-accent); and outline-offset: 2px;'
fi

if [ -n "$FOOTER_FOCUS_RULE" ] \
  && printf '%s\n' "$FOOTER_FOCUS_RULE" | grep -qF 'outline: 2px solid var(--color-accent);' \
  && printf '%s\n' "$FOOTER_FOCUS_RULE" | grep -qF 'outline-offset: 2px;'; then
  :
else
  fail 'styles.css .page-footer__link:focus-visible must declare outline: 2px solid var(--color-accent); and outline-offset: 2px;'
fi

if grep -qE 'outline:[[:space:]]*(none|0)[[:space:]]*;' styles.css; then
  fail "styles.css must not remove focus outlines with outline: none/0"
fi
echo "  [ok] visible focus contract"

# 6. Reduced motion
REDUCED_MOTION_BLOCK=$(awk '
  /@media \(prefers-reduced-motion: reduce\)/ { in_block = 1 }
  in_block { print }
  in_block && /^}/ { exit }
' styles.css)

if [ -n "$REDUCED_MOTION_BLOCK" ] \
  && printf '%s\n' "$REDUCED_MOTION_BLOCK" | grep -qF '.link-button' \
  && printf '%s\n' "$REDUCED_MOTION_BLOCK" | grep -qF '.save-contact-button' \
  && printf '%s\n' "$REDUCED_MOTION_BLOCK" | grep -qF 'transition: none;' \
  && printf '%s\n' "$REDUCED_MOTION_BLOCK" | grep -qF 'transform: none;'; then
  echo "  [ok] reduced motion contract"
else
  fail 'styles.css reduced-motion block must set transition: none; and transform: none; for .link-button and .save-contact-button'
fi

# 7. Contrast: pinned tokens plus calculated WCAG ratios
token_value() {
  awk -v token="$1" '
    $0 ~ "^[[:space:]]*" token "[[:space:]]*:" {
      value = $0
      sub(/^[^:]*:[[:space:]]*/, "", value)
      sub(/[[:space:]]*;.*/, "", value)
      print value
      exit
    }
  ' styles.css
}

CONTRAST_TOKENS=(
  '--color-gradient-1|#5a67d1'
  '--color-gradient-2|#645fcc'
  '--color-gradient-3|#705aca'
  '--color-gradient-4|#8055c8'
  '--color-gradient-5|#9252c5'
  '--color-on-surface-variant|#6b7280'
  '--color-primary|#484dc4'
  '--color-surface-container-low|#f1f4fa'
)
contrast_token_total=${#CONTRAST_TOKENS[@]}
contrast_token_present=0
contrast_token_missing=0
for entry in "${CONTRAST_TOKENS[@]}"; do
  token=${entry%%|*}
  expected=${entry#*|}
  actual=$(token_value "$token")
  if [ "$actual" = "$expected" ]; then
    contrast_token_present=$((contrast_token_present + 1))
  else
    echo "FAILED - styles.css token $token must be $expected (found ${actual:-missing})" >&2
    contrast_token_missing=$((contrast_token_missing + 1))
  fi
done

if [ "$contrast_token_missing" -gt 0 ]; then
  fail "accessibility contrast tokens are missing $contrast_token_missing of $contrast_token_total required values"
fi
echo "  [ok] accessibility contrast token values ($contrast_token_present/$contrast_token_total)"

ON_PRIMARY=$(token_value --color-on-primary)
SURFACE=$(token_value --color-surface)
ON_SURFACE=$(token_value --color-on-surface)
ON_SURFACE_VARIANT=$(token_value --color-on-surface-variant)
PRIMARY=$(token_value --color-primary)
SURFACE_CONTAINER_LOW=$(token_value --color-surface-container-low)
ACCENT=$(token_value --color-accent)
GRADIENT_1=$(token_value --color-gradient-1)
GRADIENT_2=$(token_value --color-gradient-2)
GRADIENT_3=$(token_value --color-gradient-3)
GRADIENT_4=$(token_value --color-gradient-4)
GRADIENT_5=$(token_value --color-gradient-5)

if ! CONTRAST_REPORT=$(awk \
  -v on_primary="$ON_PRIMARY" \
  -v surface="$SURFACE" \
  -v on_surface="$ON_SURFACE" \
  -v on_variant="$ON_SURFACE_VARIANT" \
  -v primary="$PRIMARY" \
  -v surface_low="$SURFACE_CONTAINER_LOW" \
  -v accent="$ACCENT" \
  -v g1="$GRADIENT_1" \
  -v g2="$GRADIENT_2" \
  -v g3="$GRADIENT_3" \
  -v g4="$GRADIENT_4" \
  -v g5="$GRADIENT_5" '
  function hexval(c) {
    return index("0123456789abcdef", tolower(c)) - 1
  }
  function parse_hex(h,   i) {
    h = tolower(h)
    sub(/^#/, "", h)
    P_R = hexval(substr(h, 1, 1)) * 16 + hexval(substr(h, 2, 1))
    P_G = hexval(substr(h, 3, 1)) * 16 + hexval(substr(h, 4, 1))
    P_B = hexval(substr(h, 5, 1)) * 16 + hexval(substr(h, 6, 1))
  }
  function linear(c) {
    c = c / 255
    if (c <= 0.04045) return c / 12.92
    return ((c + 0.055) / 1.055) ^ 2.4
  }
  function luminance(r, g, b) {
    return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
  }
  function contrast(fg, bg, lighten,   fr, fgc, fb, br, bgc, bb, l1, l2, tmp) {
    parse_hex(fg)
    fr = P_R; fgc = P_G; fb = P_B
    parse_hex(bg)
    br = P_R; bgc = P_G; bb = P_B
    if (lighten) {
      br = int(br * 1.03 + 0.5); if (br > 255) br = 255
      bgc = int(bgc * 1.03 + 0.5); if (bgc > 255) bgc = 255
      bb = int(bb * 1.03 + 0.5); if (bb > 255) bb = 255
    }
    l1 = luminance(fr, fgc, fb)
    l2 = luminance(br, bgc, bb)
    if (l1 < l2) { tmp = l1; l1 = l2; l2 = tmp }
    return (l1 + 0.05) / (l2 + 0.05)
  }
  function check(label, fg, bg, lighten,   r) {
    r = contrast(fg, bg, lighten)
    printf "  contrast %s = %.3f:1\n", label, r
    if (r < 4.5) {
      printf "FAILED - %s contrast %.3f:1 is below 4.5:1\n", label, r > "/dev/stderr"
      failed++
    } else {
      passed++
    }
  }
  BEGIN {
    passed = 0
    failed = 0
    gradients[1] = g1
    gradients[2] = g2
    gradients[3] = g3
    gradients[4] = g4
    gradients[5] = g5
    for (i = 1; i <= 5; i++) {
      check("white on gradient-" i " (rest)", on_primary, gradients[i], 0)
      check("white on gradient-" i " (hover/focus)", on_primary, gradients[i], 1)
    }
    check("on-surface-variant on surface", on_variant, surface, 0)
    check("accent on surface", accent, surface, 0)
    check("on-surface on surface", on_surface, surface, 0)
    check("primary on surface-container-low (rest)", primary, surface_low, 0)
    check("primary on surface-container-low (hover/focus)", primary, surface_low, 1)
    if (failed > 0 || passed != 15) exit 1
  }
'); then
  printf '%s\n' "$CONTRAST_REPORT"
  echo "Harness status: FAILED - accessibility contrast contract is below 4.5:1 (see failed ratios above)" >&2
  exit 1
fi

printf '%s\n' "$CONTRAST_REPORT"
echo "  [ok] accessibility contrast contract (15/15)"

# 8. Link button contrast wiring
if printf '%s\n' "$LINK_BUTTON_RULE" | grep -qF 'color: var(--color-on-primary);' \
  && printf '%s\n' "$LINK_BUTTON_RULE" | grep -qF 'background: var(--link-button-bg);'; then
  :
else
  fail 'styles.css .link-button must use color: var(--color-on-primary); and background: var(--link-button-bg);'
fi

gradient_wiring_missing=0
for gradient in 1 2 3 4 5; do
  gradient_rule=$(awk -v selector=".link-button--gradient-$gradient" '
    $1 == selector && $2 == "{" { in_rule = 1 }
    in_rule { print }
    in_rule && /}/ { exit }
  ' styles.css)
  if printf '%s\n' "$gradient_rule" | grep -qF -- "--link-button-bg: var(--color-gradient-$gradient);"; then
    :
  else
    echo "FAILED - .link-button--gradient-$gradient must assign --link-button-bg: var(--color-gradient-$gradient);" >&2
    gradient_wiring_missing=$((gradient_wiring_missing + 1))
  fi
done
if [ "$gradient_wiring_missing" -gt 0 ]; then
  fail "accessibility link button wiring is missing $gradient_wiring_missing of 5 gradient assignments"
fi

LINK_HOVER_RULE=$(awk '
  /^[[:space:]]*\.link-button:hover[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$LINK_HOVER_RULE" ] \
  && printf '%s\n' "$LINK_HOVER_RULE" | grep -qF 'filter: brightness(1.03);' \
  && printf '%s\n' "$LINK_FOCUS_RULE" | grep -qF 'filter: brightness(1.03);'; then
  echo "  [ok] link button contrast wiring"
else
  fail 'styles.css .link-button hover/focus must retain filter: brightness(1.03);'
fi

echo "Serving command: python3 -m http.server 3413 --directory ."
echo "Manual verification: open http://localhost:3413 in a mobile viewport (390×844) and a desktop viewport (1280×800)."

if [ "${RUN_SERVE_COMMAND:-0}" = "1" ]; then
  exec python3 -m http.server 3413 --directory .
fi
