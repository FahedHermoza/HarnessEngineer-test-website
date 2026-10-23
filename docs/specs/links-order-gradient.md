# Feature Implementation Spec: Orden de Enlaces y degradado lavanda→violeta

## Source Feature

- `id`: `links-order-gradient`
- `area`: `links`
- `depends_on`: `link-instagram`, `link-facebook`, `link-whatsapp`, `link-linkedin`, `link-portafolio`, `link-correo`, `link-celular` (all `accepted` at planning time)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: reference order in `docs/build-brief.md` / `CONTEXT.md`; five-tone ramp in `DESIGN.md` (`colors`, `Open Design Questions`); deferred demo removal recorded in `PROGRESS.md` “Current deferred work”.

## Goal

Make the Enlaces column match the product contract: the seven real anchors appear in exactly this order — **Instagram, Facebook, WhatsApp, LinkedIn, Portafolio, Correo, Celular** — with a continuous lavender→violet progression and `space-sm` (12px) vertical separation, and remove the temporary `[data-demo="link-button"]` block and its CSS that were kept only until this integration feature.

The slice ends when the order, the seven tone assignments, the `space-sm` gap, the demo absence and the existing component/keyboard behavior are verified by `./init.sh` plus browser checks at 390×844 and 1280×800, with evidence registered. No new data model, route, JS or dependency is introduced.

## Non-Goals

- Do not add the eighth “Guardar contacto” button, the vCard, avatar fallback, accessibility fixes, responsive breakpoints, OG/deploy work or any other feature.
- Do not change URLs, labels, `aria-label`s, SVG icons, `target`/`rel`, component base styles, hover/focus states, the page shell, Perfil, pie or metadata.
- Do not add or change `:root` tokens; do not invent palette colors; do not introduce JS, frameworks, bundlers, npm or assets.
- Do not resolve the inherited AA contrast deviation of white labels (3.86–4.13:1); it stays with `accessibility-baseline`.
- Do not activate external destinations (`tel:`, `mailto:`, social links) during automated verification.
- Do not change `./init.sh` semantics: it must stay non-blocking for bootstrapping and must not start a server by default.

## Job Story

When abro la Tarjeta digital en el móvil,
I want ver los siete Enlaces en el orden acordado y con una progresión de color suave,
so I can encontrar el canal correcto rápido y percibir la tarjeta como una sola pieza de diseño coherente.

## Users And Permissions

- Visitante anónimo: ve y activa los siete Enlaces; sin autenticación, estado ni permisos.
- Propietario/agente: mantiene el orden y el tono editando únicamente `index.html` y `styles.css`.
- Implementador/validador: amplía el gate y verifica en navegador; no implementa otras features.

## Acceptance Scenarios

### Scenario 1: Orden exacto de los siete Enlaces

Given la Tarjeta digital servida,
When se inspecciona el único `<nav class="links" aria-label="Enlaces de contacto">`,
Then hay exactamente 7 anclas de producto y sus etiquetas visibles, en orden, son `Instagram`, `Facebook`, `WhatsApp`, `LinkedIn`, `Portafolio`, `Correo`, `Celular`.

### Scenario 2: Progresión continua sin saltos

Given los siete Enlaces renderizados,
When se leen sus clases de tono y sus `background-color` computados,
Then cada posición usa el tono de la tabla de abajo, la secuencia es monótona lavanda→violeta (de `#6876f0` a `#a85ee2`) y ningún salto entre botones consecutivos supera el mayor salto interno de la paleta (14/255 por canal).

### Scenario 3: Separación y geometría

Given 390×844 y 1280×800,
When se miden los botones,
Then cada uno mide 48px de alto, ocupa el ancho interior de `.links` (308px en móvil, 350px en escritorio con la tarjeta de 400px) y la separación vertical entre botones consecutivos es exactamente 12px (`var(--space-sm)`), sin scroll horizontal.

### Scenario 4: Retirada de la demo temporal

Given la implementación terminada,
When se busca `[data-demo="link-button"]`, `#link-button-demo` o las etiquetas `Enlace uno`…`Enlace cinco`,
Then no existen en `index.html` ni en `styles.css`; el documento contiene exactamente 7 anclas con clases `.link-button` (todas de producto) y el contrato del componente `.link-button` sigue intacto.

### Scenario 5: Estados heredados y accesibilidad

Given el primer Enlace enfocado con `Tab` en escritorio,
When se fuerza `:hover` y luego `prefers-reduced-motion: reduce`,
Then se mantienen el outline `rgb(88, 92, 229) solid 2px` con offset 2px, `translateY(-1.5px)`/sombra hover/`brightness(1.03)` en hover y, con movimiento reducido, `transition-duration: 0s` y `transform: none`.

### Scenario 6: Consola y red limpias

Given la página servida en 390×844 y 1280×800 con recarga fresca,
When se carga,
Then la consola muestra 0 mensajes y todas las peticiones responden 2xx/3xx (documento, Google Fonts CSS, `styles.css`, `assets/avatar.jpg`, WOFF2), sin `/favicon.ico`.

### Scenario 7: El gate detecta regresiones

Given una copia temporal con LinkedIn y Portafolio intercambiados, una clase de tono alterada, una regla de interpolación eliminada, la demo reintroducida o el `gap` cambiado,
When se ejecuta `./init.sh`,
Then sale con código 1, imprime en stderr el check concreto y no deja ningún listener en el puerto sugerido.

## Repository Research

### Files Inspected

- `index.html` — current `.links` nav has 7 anchors but order is Instagram, Facebook, WhatsApp, **Portafolio, LinkedIn**, Correo, Celular; only Facebook and WhatsApp carry an explicit `link-button--gradient-1`, the other five have no modifier and fall back to `gradient-1`; demo `section#link-button-demo[data-demo="link-button"]` still present with 5 anchors.
- `styles.css` — `.links` already has `display:flex`, `flex-direction:column`, `gap:var(--space-sm)`, `padding:0 var(--space-lg)` (added in Session 024); five `.link-button--gradient-N` modifiers exist; `[data-demo="link-button"]` CSS block at the end must be removed.
- `init.sh` — 939 lines; contains several gates whose interim assumptions conflict with this feature: Instagram rejects any `link-button--gradient-*` (line ~785), Facebook requires `gradient-1` (line ~565), LinkedIn regex expects `class="link-button"` exactly, Correo extracts an exact opening line without modifier, Celular/global markup checks use `grep -F 'class="link-button"'`, and Instagram checks require the demo and its 5 labels to exist (lines ~861–881).
- `DESIGN.md` — five tones, white labels/icons, `space-sm` separation, and an open question on how to extend 5 tones to 7–8 buttons.
- `docs/build-brief.md`, `CONTEXT.md`, `docs/domain-model.md` — canonical order of the seven Enlaces; an Enlace has a position/order.
- `docs/technical-discovery.md` — static HTML/CSS, no build, no frameworks/bundlers, SVG inline, Google Fonts.
- `feature_list.json`, `PROGRESS.md` — seven Enlace features accepted; demo removal explicitly deferred to this feature; inherited contrast risk recorded.

### Existing Patterns To Follow

- One `<nav class="links">`; BEM-ish component classes; explicit tone modifiers instead of `:nth-child`.
- Token-only colors/typography/spacing; no new `:root` declarations.
- Additive, non-blocking `init.sh` gates with `[ok]` lines and concrete `FAILED - …` stderr messages.
- Verification with `python3 -m http.server <free port> --directory .`, Chrome DevTools at 390×844 and 1280×800, and negative cases in temporary copies outside the repo.

### Current Gaps

- Required order is not implemented (Portafolio precedes LinkedIn).
- Only Instagram currently matches its final tone; Facebook/WhatsApp use `gradient-1` and the other four have no modifier.
- No gate asserts order, anchor count, final tone map or demo absence.
- `DESIGN.md` does not state how the ramp is extended to 7 Enlaces.
- No persistent E2E harness exists; adding one would require forbidden dependencies.

## Technical Approach

### Final markup order and tone map

Modify only the class attribute order/tones in the existing nav; keep every `href`, visible label, `aria-label` and inline SVG unchanged.

| # | Label | Class | Effective color | Computed serialization |
|---|-------|-------|-----------------|------------------------|
| 1 | Instagram | `link-button link-button--gradient-1` | `#6876f0` | `rgb(104, 118, 240)` |
| 2 | Facebook | `link-button link-button--gradient-2` | `#736deb` | `rgb(115, 109, 235)` |
| 3 | WhatsApp | `link-button link-button--gradient-3` | `#8168e8` | `rgb(129, 104, 232)` |
| 4 | LinkedIn | `link-button link-button--gradient-3-4` | `#8a65e7` | `color(srgb 0.541176 0.396078 0.905882)` |
| 5 | Portafolio | `link-button link-button--gradient-4` | `#9362e6` | `rgb(147, 98, 230)` |
| 6 | Correo | `link-button link-button--gradient-4-5` | ≈ `#9e60e4` (157.5, 96, 228) | `color(srgb 0.617647 0.376471 0.894118)` |
| 7 | Celular | `link-button link-button--gradient-5` | `#a85ee2` | `rgb(168, 94, 226)` |

Rationale: the two largest palette steps are `gradient-3→gradient-4` and `gradient-4→gradient-5`; inserting one 50/50 midpoint in each keeps every consecutive step within the palette’s own maximum (≤14/255 per channel), preserves all five authorized tones, stays monotonic lavender→violet and avoids the abrupt reset of repeating `1,2` after `5`.

### CSS additions

After the five existing modifiers (before `@media (hover: hover)`):

```css
/* Fallback for browsers without color-mix: lower anchor tone. */
.link-button--gradient-3-4 {
  --link-button-bg: var(--color-gradient-3);
}

.link-button--gradient-4-5 {
  --link-button-bg: var(--color-gradient-4);
}

@supports (color: color-mix(in srgb, red, blue)) {
  .link-button--gradient-3-4 {
    --link-button-bg: color-mix(in srgb, var(--color-gradient-3), var(--color-gradient-4));
  }

  .link-button--gradient-4-5 {
    --link-button-bg: color-mix(in srgb, var(--color-gradient-4), var(--color-gradient-5));
  }
}
```

Do not alter the base `.link-button` rule, its hover/focus/reduced-motion blocks, or `.links` (gap/padding are already correct).

### Remove the temporary demo

- Delete the comment and `<section id="link-button-demo" data-demo="link-button" …>…</section>` from `index.html`.
- Delete the `[data-demo="link-button"]` CSS block and its comment.
- Keep `link-instagram`’s footer Instagram link untouched; it is outside the nav.

### Harness (`init.sh`) changes

Add an `Order and gradient checks:` section after the existing link checks:

- `.links` exists; the nav contains exactly 7 `<span class="link-button__label">` entries.
- Extract the ordered label list from `LINKS_BLOCK` and compare to `Instagram|Facebook|WhatsApp|LinkedIn|Portafolio|Correo|Celular`.
- Extract the ordered opening-class list (`<a … class="link-button[^"]*"`) and compare to the seven classes in the table.
- Require the two `color-mix` expressions and the `@supports (color: color-mix(in srgb, red, blue))` guard in `styles.css`.
- Require `[data-demo="link-button"]` and `#link-button-demo` to be absent from both files.
- Keep the existing `.links` gap/padding gates.

Update the existing gates so they no longer encode interim assumptions, without losing coverage:

- Instagram: replace “must not use a modifier” with “uses `link-button--gradient-1`”.
- Facebook: expect `class="link-button link-button--gradient-2"`.
- LinkedIn: allow `class="link-button[^"]*"`; keep its destination.
- Correo: extract by `href="mailto:fahedhermoza@gmail.com"` (not the exact modifier-free line); keep its 7-item contract.
- Celular: replace the exact `class="link-button"` match with an anchor-based check or `class="link-button[^"]*"`; keep destination/aria-label.
- Instagram demo-presence checks: invert to absence checks (also covered by the new section).

These edits intentionally supersede the interim negative cases of the seven Enlace features (e.g. “Instagram must not use a modifier” in `link-instagram`); this feature owns the final tone assignment, and their historical validation records remain valid for their own slices.

Suggested order extraction (macOS-compatible):

```bash
LINK_LABELS=$(printf '%s\n' "$LINKS_BLOCK" \
  | grep -oE '<span class="link-button__label">[^<]+</span>' \
  | sed -E 's/^.*>([^<]+)<.*$/\1/' | paste -sd '|' -)
LINK_CLASSES=$(printf '%s\n' "$LINKS_BLOCK" \
  | grep -oE '<a[^>]*class="link-button[^"]*"' \
  | sed -E 's/^.*class="([^"]+)".*$/\1/' | paste -sd '|' -)
```

## Expected File Changes

- `index.html` — modify; reorder LinkedIn/Portafolio, assign the seven tone classes, remove the demo section and its comment.
- `styles.css` — modify; add the two midpoint modifiers + `@supports`, remove the `[data-demo="link-button"]` block.
- `init.sh` — modify; add order/tonal/demo-absence gates and relax the five interim gates.
- `DESIGN.md` — update; record the resolved 7-link ramp (five tones + two midpoints) and mark the “cómo se repite/extiende” question resolved for Enlaces (Guardar contacto stays neutral).
- `docs/risks-and-open-questions.md` — update one line; state that the two interpolated tones measure 4.12:1 and 4.00:1, so the inherited range stays 3.86–4.13:1 and remains deferred.
- `feature_list.json`, `PROGRESS.md` — modify; set `links-order-gradient` to `passing` with evidence and log the session (validator later moves it to `accepted`).
- `docs/specs/links-order-gradient.md` — this spec (no product code).

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` (`colors` gradient-1…5, `components/button-link`, `Layout`, `Accessibility Baseline`).
- Screens/states affected: the single Tarjeta digital view — the Enlaces column only (order, seven tones, 12px gap); demo block disappears.
- New design artifact required: no — derived midpoint tones use existing palette tokens via `color-mix`; no new hex values or fonts.
- Inherited deviation: white labels over the seven tones measure 3.86–4.13:1 (AA 4.5:1 not met), unchanged and deferred to `accessibility-baseline`.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no new layer, surface or dependency (file does not exist; do not create it).
- `CONSTRAINTS.md`: not needed — no new durable MUST/MUST NOT beyond this slice (file does not exist; do not create it).
- `AGENTS.md`: not needed — startup path, workflow and verification semantics are unchanged.
- `DESIGN.md`: update — resolve the 5→7 ramp question and document the midpoint approach.
- `docs/risks-and-open-questions.md`: update — extend the inherited contrast note with the two interpolated tones.
- `CONTEXT.md` / `docs/domain-model.md`: not needed — order and Enlace semantics already documented.

## Implementation Plan

1. Run `./init.sh` to confirm the current baseline is green before editing.
2. Reorder the nav anchors (LinkedIn before Portafolio) and apply the seven tone classes from the table; leave all content/attributes intact.
3. Add the two midpoint modifier rules with the `@supports` guard; remove the temporary demo CSS block.
4. Remove the demo section/comment from `index.html`; confirm exactly 7 anchors remain.
5. Extend `init.sh` with count/order/tone/`color-mix`/demo-absence gates and relax the five interim gates; keep the script non-blocking and server-free by default.
6. Update `DESIGN.md`, `docs/risks-and-open-questions.md`, `feature_list.json` and `PROGRESS.md`.
7. Run `bash -n init.sh` and `./init.sh`; run negative cases; verify both viewports in the browser; record evidence.

## Implementation Tasks

- [ ] Confirm the baseline: `bash -n init.sh && ./init.sh` exits 0.
- [ ] Reorder anchors to Instagram → Facebook → WhatsApp → LinkedIn → Portafolio → Correo → Celular.
- [ ] Apply the seven tone classes exactly as tabulated; do not change `href`, labels, `aria-label`, icons, `target`/`rel`.
- [ ] Add `.link-button--gradient-3-4` / `-4-5` with fallback plus `@supports` `color-mix` rules.
- [ ] Remove the demo section/comment and the `[data-demo="link-button"]` CSS block.
- [ ] Add the order/tone/`color-mix`/demo-absence gates to `init.sh`.
- [ ] Update the Instagram, Facebook, LinkedIn, Correo and Celular gates for the new modifiers.
- [ ] Update `DESIGN.md` (resolved ramp) and the contrast note in `docs/risks-and-open-questions.md`.
- [ ] Register `passing` + evidence in `feature_list.json` and a session entry in `PROGRESS.md`.

## Verification Plan

- `bash -n init.sh` → no syntax errors.
- `./init.sh` → exit 0, `Harness status: bootstrapped`, all prior checks `[ok]`, new checks (suggested labels): `[ok] links order (7/7)`, `[ok] links tone progression (7/7)`, `[ok] interpolated tone rules (2/2)`, `[ok] link button demo removed`; no server started.
- Negative cases in temporary copies outside the repo (repo intact; delete copies): (1) LinkedIn/Portafolio swapped → order gate `exit 1`; (2) Correo without `--gradient-4-5` → tone gate `exit 1`; (3) remove one `color-mix` rule → CSS gate `exit 1`; (4) reintroduce the demo section → demo-absence gate `exit 1`; (5) change `gap` to `space-md` → existing gap gate `exit 1`. Every failure must show a concrete `FAILED - …` message and no listener on 3301.
- `python3 -m http.server 3301 --directory .` (free port; stop afterwards): `curl -sI /` and `/styles.css` → 200; `/assets/avatar.jpg` → 200 `image/jpeg`; server log without 4xx/5xx or `/favicon.ico`.
- Browser 390×844 and 1280×800 (fresh reload, cache ignored): console 0 messages; requests 2xx/3xx incl. Google Fonts/avatar/WOFF2; no `/favicon.ico`; `scrollWidth === clientWidth`; 7 anchors in exact order; exactly 7 anchors with `.link-button` classes and no `[data-demo]`/`#link-button-demo`.
- Geometry: each anchor 48px high, full `.links` width, `padding: 0px 20px`, radius 6px, `justify-content:space-between`, 11px/800/1.98px uppercase; gap between consecutive rects = 12px; links 308×48 at 390 and 350×48 at 1280 (desktop `clientWidth` may be 1265 with a classic scrollbar; measure relative geometry, not absolute `x`).
- Colors: computed backgrounds match the table (solid tones as `rgb(...)`; interpolated ones as `color(srgb …)`), sequence is monotonic and each adjacent delta ≤14/255 per channel. Verify the `@supports` fallback exists in source (do not need to disable `color-mix`).
- States: first `Tab` → visible outline `rgb(88, 92, 229) solid 2px` offset 2px; real hover → `matrix(1, 0, 0, 1, 0, -1.5)`, hover shadow `rgba(108, 114, 234, 0.28) 0px 8px 18px 0px`, `brightness(1.03)`; `prefers-reduced-motion: reduce` → `transition-duration: 0s`, `transform: none`.
- Do not activate external links; destination/aria coverage is already accepted in the seven Enlace features.
- E2E: no persistent harness exists and adding one would introduce dependencies forbidden by `docs/technical-discovery.md`; the `init.sh` gate + browser checks are the agreed verification.

## Evidence To Capture

- `bash -n` and `./init.sh` output (all `[ok]`, exit 0, no server).
- Negative-case stderr for the five mutations and confirmation that no listener starts.
- Browser tables for 390×844 and 1280×800: order, 7 anchors, widths/heights, 12px gaps, no horizontal scroll, console 0, request list without failures or `/favicon.ico`.
- Computed `background-color` per label and the contrast values (3.86–4.13:1) recorded as inherited risk.
- `feature_list.json` evidence + `PROGRESS.md` session entry; optional screenshots (note if the model cannot interpret them).

## Validator Checklist

- [ ] Exactly 7 product Enlaces, in the required order, with no demo remnants in HTML or CSS.
- [ ] Tone classes and computed backgrounds match the table; progression is monotonic with no step above 14/255 per channel.
- [ ] `.links` keeps `space-sm` gap and gutter padding; no horizontal scroll at 390×844 or 1280×800.
- [ ] Component, hover, focus-visible and reduced-motion behavior unchanged.
- [ ] `./init.sh` exits 0 without starting a server and catches all five negative cases.
- [ ] Scope respected: no URLs/labels/icons changed, no vCard/accessibility/responsive/deploy work, no new tokens, JS, dependencies or assets.
- [ ] `DESIGN.md` and the inherited contrast note were updated; `feature_list.json` and `PROGRESS.md` evidence is accurate.
- [ ] No unrelated product behavior was added.

## Risks And Open Questions

- **Derived tones:** `color-mix` produces colors that are not literal palette hex values but are derived only from `--color-gradient-3/4/5`; DESIGN.md explicitly allows interpolation. The `@supports` fallback prevents transparent buttons on unsupported browsers (they get the lower anchor tone).
- **Inherited contrast:** white on the seven tones remains 3.86–4.13:1, below AA; explicitly deferred to `accessibility-baseline`.
- **Shared files:** `save-contact-vcard` (8th button) and `responsive-baseline` will touch the same files; keep this diff limited to order/tones/demo and make the new gates easy to extend (the order gate will need an update when an 8th neutral button is added).
- **No blocking unknowns.** The “Guardar contacto” treatment remains deferred and neutral per `DESIGN.md`.
