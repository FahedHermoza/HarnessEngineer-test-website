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
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'class="link-button link-button--gradient-1"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF '<span class="link-button__label">Facebook</span>' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'aria-label="Facebook de Fahed Hermoza"'; then
  echo "  [ok] facebook link markup"
else
  fail "index.html is missing the Facebook link markup (href, .link-button--gradient-1, visible label or accessible name)"
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
  *link-button--gradient-*)
    fail "the Instagram Enlace must not use a link-button--gradient-* modifier (tone assignment belongs to links-order-gradient)"
    ;;
  *)
    echo "  [ok] Instagram Enlace uses the component base tone"
    ;;
esac

instagram_link_count=$(printf '%s\n' "$LINKS_BLOCK" | grep -o 'class="link-button"' | wc -l || true)
if [ "$instagram_link_count" -eq 1 ]; then
  echo "  [ok] Instagram Enlace markup"
else
  fail "index.html must contain exactly one class=\"link-button\" Enlace inside the links navigation (found $instagram_link_count)"
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
  echo "  [ok] link button demo preserved"
else
  fail "index.html is missing the temporary link button demo [data-demo=\"link-button\"] (must be preserved in this feature)"
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
    :
  else
    fail "index.html is missing the temporary link button demo label: $label"
  fi
done
echo "  [ok] link button demo labels preserved (5/5)"

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

echo "Serving command: python3 -m http.server 3301 --directory ."
echo "Manual verification: open http://localhost:3301 in a mobile viewport (390×844) and a desktop viewport (1280×800)."

if [ "${RUN_SERVE_COMMAND:-0}" = "1" ]; then
  exec python3 -m http.server 3301 --directory .
fi
