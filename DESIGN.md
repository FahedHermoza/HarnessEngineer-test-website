---
name: Serene Bio Card
description: Tarjeta digital de enlaces personales con estética minimalista cálida, tarjeta blanca flotante y botones en degradado lavanda→violeta.
designAssets:
  sourceOfTruth: []
  references:
    - url: https://0a41b4efa061ab62.demo.carrd.co
      role: Carrd Template #93, base estructural de la tarjeta
      status: inspiration
  generatedConcepts: []
  ownerProvided:
    - path: assets/avatar.jpg
      role: Foto de perfil (la aporta Fahed)
      status: available
    - path: assets/og-image.jpg
      role: Imagen Open Graph 1200×630
      status: available (aprobada el 2026-10-23)
colors:
  background: '#f7f9ff'
  surface: '#ffffff'
  surface-container-low: '#f1f4fa'
  border: '#ebeef2'
  on-surface: '#2d3139'
  on-surface-variant: '#6b7280'
  outline: '#767685'
  primary: '#484dc4'
  on-primary: '#ffffff'
  accent: '#585ce5'
  gradient-1: '#5c68d4'
  gradient-2: '#6a64d8'
  gradient-3: '#765fd4'
  gradient-4: '#8659d1'
  gradient-5: '#9654c9'
  error: '#ba1a1a'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.015em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  button-label:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '800'
    lineHeight: 16px
    letterSpacing: 0.18em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.5rem
  space-xs: 0.375rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
components:
  card:
    backgroundColor: '{colors.surface}'
    rounded: 24px
    shadow: '0 24px 64px -28px rgba(45, 49, 57, 0.16), 0 8px 24px -10px rgba(45, 49, 57, 0.08)'
    border: '1px solid {colors.border}'
  profile:
    headerGap: 24px
    headerPadding: '36px 24px 0'
    identityPadding: '20px 24px 34px'
    handleFont: '13px / 600 / 20px'
    topRow: 'flex row, space-between, full width — NFC icon+label at left, external-link icon at right; avatar centered below'
    nfcLabel: 'NFC broadcast icon + "NFC CONNECT" text, top-left, ornamental, hidden from assistive technology'
    nfcLabelStyle: 'label-sm (11px / 600 / 16px, 0.05em) uppercase in {colors.primary}; inline NFC-waves SVG icon 14px with currentColor; NOT a pill (no border, radius or background)'
    openIcon: 'external-link SVG icon 18px, currentColor in {colors.on-surface-variant}, decorative (aria-hidden), top-right; not an interactive control in this slice'
    decorativeDot: '#2f8f65 dot (16px, 3px {colors.surface} halo) placed on the avatar bottom-right (place-self: end), ornamental'
  button-link:
    height: 48px
    rounded: '{rounded.md}'
    textColor: '{colors.on-primary}'
    font: '{typography.button-label}'
  save-contact:
    height: 48px
    rounded: '{rounded.md}'
    backgroundColor: '{colors.surface-container-low}'
    textColor: '{colors.primary}'
    font: '{typography.button-label}'
  avatar:
    size: 88px
    rounded: '{rounded.full}'
---

# Design Direction

## Overview

"Serene Bio Card" es un sistema visual de tarjeta personal tipo link-in-bio. Una tarjeta blanca flotante sobre un lienzo neutro cálido, con jerarquía tipográfica tranquila y botones de acción de ancho completo que recorren un degradado lavanda→violeta. El objetivo es claridad, elegancia y tacto simple: que el visitante entienda quién es Fahed y toque el canal correcto sin esfuerzo.

## Existing Design Assets

- **Carrd Template #93** — `https://0a41b4efa061ab62.demo.carrd.co` — *inspiration only*. Define la estructura base: tarjeta centrada, avatar circular, handle en gris, divisores finos, botones de ancho completo con icono a la derecha. No es fuente de verdad.
- **`assets/avatar.jpg`** — foto de perfil; ya presente en el repositorio.
- **`assets/og-image.jpg`** — imagen Open Graph 1200×630. Estado: disponible y aprobada por el propietario el 2026-10-23; composición reproducible documentada abajo.

Autoridad: los tokens, reglas de layout y guía de componentes de este documento son la fuente de verdad cuando el template o las imágenes entren en conflicto.

## Generated Concept Images

La `og-image` no es un concepto de IA: se generó con la receta reproducible del spec
`deploy-cloudflare-pages` (HTML temporal no commiteado + captura de Chrome a 1200×630 y
JPEG calidad 90). El agente no interpreta la imagen resultante; la aprobación de la
composición es humana.

## Product Feel

Minimalismo cálido y etéreo. Mucho aire, geometría refinada, autoridad tipográfica discreta y microinteracciones suaves. Nada de ruido digital ni bordes duros.

## Colors

- **Fondo (canvas):** `#f7f9ff` — off-white frío suave que da contraste a la tarjeta.
- **Superficie (tarjeta):** `#ffffff` — contenedor limpio y suave.
- **Borde / divisores:** `#ebeef2` — reglas finas, sin estructura agresiva.
- **Texto principal:** `#2d3139` — gris pizarra profundo, no negro puro.
- **Texto secundario / meta:** `#6b7280` — para handle y tagline; el pie usa `#2d3139`.
- **Acento / enlaces:** `#585ce5`.
- **Punto verde ornamental del avatar:** `#2f8f65`, color local del ornamento, no token
  global; se posa en la esquina inferior derecha del avatar y no indica disponibilidad,
  conexión NFC ni presencia.
- **Icono de enlace externo (tinta neutra):** usa `#6b7280` (`on-surface-variant`) vía
  `currentColor`; decorativo, sin relleno de color de marca.
- **Degradado de botones** (secuencia descendente en la pila de Enlaces), rampa adoptada del sistema Stitch (periwinkle→orquídea) y **ajustada para AA** (ver nota abajo):
  1. `#5c68d4`
  2. `#6a64d8`
  3. `#765fd4`
  4. `#8659d1`
  5. `#9654c9`
  El texto y el icono de todos los botones van siempre en `#ffffff`.

> **Nota de reconciliación (AA).** El export Stitch proponía la rampa `#6876F0 · #736DEB · #8168E8 · #9362E6 · #A85EE2`. Con texto blanco esos tonos dan 3.65–4.13:1, por debajo del mínimo AA de 4.5:1 (y peor en hover con `brightness(1.03)`). Para conservar el matiz periwinkle→orquídea sin romper la base AA de `CONSTRAINTS.md`, la rampa se oscurece ~10% a los valores de arriba, que pasan 4.52–4.82:1 en reposo y hover. Aprobado por el propietario el 2026-11-22.

Tras `redesign-contact-navigation`, la pila de Enlaces son **cinco botones grandes** (Celular y Correo se movieron a la fila de Acciones rápidas, ver abajo). La progresión recorre la rampa desde `gradient-1` hasta `gradient-4`, insertando un intermedio 50/50 en el salto 3→4, sin repetir tonos ni superar 14/255 por canal entre botones consecutivos:

1. Instagram — `gradient-1` `#5c68d4`
2. Facebook — `gradient-2` `#6a64d8`
3. WhatsApp — `gradient-3` `#765fd4`
4. LinkedIn — intermedio `gradient-3`/`gradient-4` ≈ `#7e5cd2`
5. Portafolio — `gradient-4` `#8659d1`

El intermedio se deriva con `color-mix` a partir de los tokens existentes (con fallback al tono inferior). No se añaden colores ni tokens. Los tokens `gradient-5` (`#9654c9`) y el intermedio `gradient-4`/`gradient-5` **se conservan en la paleta pero ya no se asignan a ningún botón grande** (eran Celular y Correo, hoy Acciones rápidas); su regla CSS queda disponible por si una feature posterior la reutiliza.

- **Acciones rápidas (Celular, Correo):** fuera de la rampa de degradado. Botones **circulares neutros** (48×48, `rounded.full`), superficie `#f1f4fa` (`surface-container-low`) e icono en `#484dc4` (`primary`), con `aria-label` propio e icono SVG decorativo. Fila centrada entre la identidad y la pila de Enlaces. QR y Compartir se añaden a esta misma fila en features posteriores.

El botón "Guardar contacto" queda fuera de la rampa con tratamiento neutro (superficie `#f1f4fa` con texto `#484dc4`) para diferenciarse de los Enlaces externos.

## Typography

Familia única **Plus Jakarta Sans**, con pila de respaldo del sistema (`system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`).

- **Nombre:** `headline-lg`, peso 600, tracking negativo sutil.
- **Handle:** `body-md`, peso 600, sobre superficie con contraste AA.
- **Tagline:** `body-md`, color `#6b7280`.
- **Etiquetas de botón:** `button-label` en mayúsculas, tracking `0.18em`, peso 800.
- **Pie / meta:** `body-sm` o `body-md` con enlaces en `#585ce5` subrayados.

## Layout

- Tarjeta única centrada vertical y horizontalmente en escritorio; con márgenes seguros en móvil.
- Ancho máximo de tarjeta: 380–420px en escritorio; `calc(100vw - 2rem)` en móvil.
- Columna única. Bloques separados por divisores de 1px a ancho completo de la tarjeta.
- Perfil con una fila superior a ancho completo (`space-between`): a la izquierda el rótulo
  «NFC CONNECT» (icono de ondas NFC + texto) en color de marca, a la derecha un icono
  decorativo de enlace externo en tinta neutra. El avatar queda centrado debajo con 24px
  entre la fila superior y el avatar y 36px de padding superior. El punto verde ornamental
  se posa en la esquina inferior derecha del avatar. La identidad conserva 20px de padding
  superior y 34px inferior. Botones con separación vertical `space-sm` (0.75rem); pie con
  `space-lg`.

## Shapes

- Tarjeta renovada: esquinas de `24px`, borde `1px #ebeef2` y sombra compuesta tenue.
- Botones: `6–8px` (`rounded.md`), forma estructurada tipo pill suave.
- Avatar: círculo perfecto con anillo blanco de 3px.
- Badges / chips secundarios: `6px`.

## Components

- **Perfil (slice `redesign-card-profile`):** fila superior a ancho completo con
  `justify-content: space-between`. A la izquierda, el rótulo `NFC CONNECT` como icono de
  ondas NFC (SVG inline de 14px, `currentColor`) + texto `label-sm` (11px/600/16px, tracking
  0.05em) en mayúsculas y color de marca `#484dc4` (`primary`); **no** es una píldora (sin
  borde, radio ni fondo). A la derecha, un icono decorativo de enlace externo (SVG inline de
  18px, `currentColor` en `#6b7280`, `on-surface-variant`), puramente ornamental en este
  slice (no es enlace, Compartir ni QR; esas son features posteriores). El punto verde
  ornamental `#2f8f65` (16px, halo de 3px en superficie blanca) se posa en la esquina
  inferior derecha del frame del avatar (`place-self: end`). El rótulo, su icono, el icono de
  enlace externo y el punto están dentro de elementos `aria-hidden="true"` y no anuncian
  estado, control ni conexión activa. Avatar local circular 88×88 con `object-fit: cover`,
  halo blanco y fallback `FH` de igual tamaño. Nombre en `headline-lg`; Handle debajo en
  `body-md` 13px/600 y Tagline en `body-md` 13px/400 con `lang="en"`.
- **Tarjeta (slice `redesign-card-profile`):** superficie `#ffffff`, borde
  `1px solid #ebeef2`, radio 24px y sombra
  `0 24px 64px -28px rgba(45, 49, 57, 0.16), 0 8px 24px -10px rgba(45, 49, 57, 0.08)`.
  Se conserva la fórmula responsive `min(400px, calc(100vw - 2rem))`.
- **Botón de Enlace:** ancho completo, alto 48px, padding horizontal 1.25rem, flexbox `space-between` (etiqueta mayúsculas a la izquierda, icono SVG 18px a la derecha), fondo del degradado, sombra `0 2px 6px rgba(108,114,234,0.15)`. Hover/focus: `translateY(-1.5px)`, sombra `0 8px 18px rgba(108,114,234,0.28)`, `filter: brightness(1.03)`. Transición 180ms ease.
- **Guardar contacto:** misma forma que un Enlace (`width: 100%`, 48px, padding horizontal 1.25rem, radio `rounded.md`, flexbox `space-between`, etiqueta `button-label` en mayúsculas e icono SVG 18px a la derecha), pero fuera de la rampa: fondo `#f1f4fa` (`surface-container-low`) y texto/icono `#484dc4` (`primary`). Sombra base `0 2px 6px rgba(25,30,48,0.08)`; hover/focus `translateY(-1.5px)`, sombra `0 8px 18px rgba(25,30,48,0.12)`, `filter: brightness(1.03)` y outline de acento 2px/offset 2px. Dispara la descarga de `assets/fahedhermoza.vcf` con un `<a download>`, sin JavaScript. Se separa del último Enlace con `space-sm` (12px) y del pie con el margen propio del pie.
- **Pie:** borde superior `1px #ebeef2`, texto centrado, correo y handle con enlaces acentuados.

## Sistema de diseño ampliado (export Stitch, adoptado 2026-11-22)

Esta sección adopta como fuente de verdad el sistema "Serene Bio Card" del export Stitch,
reconciliado con la base AA y responsive de este repositorio. Los tokens **efectivamente
vinculados en `styles.css`** son los del front-matter `colors:` (contrato verificado por el
gate `Design conformance checks:`); el resto de la escala se documenta aquí como paleta del
sistema para componentes presentes y futuros, sin obligar a implementarla entera.

### Marca y estética

Minimalismo cálido y etéreo para marca personal, portafolio y link-in-bio: contenedor
flotante y táctil sobre un lienzo neutro cálido, transiciones de botón periwinkle→orquídea
por ítem, mucho aire, geometría refinada y autoridad tipográfica discreta. Claridad,
elegancia y simplicidad táctil por encima del ruido digital.

### Paleta extendida (escala del sistema; no todos los tokens se vinculan hoy)

- Superficies: `surface-dim #d7dae1`, `surface-bright #f7f9ff`, `surface-container-lowest #ffffff`,
  `surface-container-low #f1f4fa`, `surface-container #ebeef5`, `surface-container-high #e5e8ef`,
  `surface-container-highest #e0e2e9`, `surface-variant #e0e2e9`.
- Texto/contorno: `on-surface #2d3139`* , `on-surface-variant #6b7280`*, `outline #767685`,
  `outline-variant #c6c5d6`, `inverse-surface #2d3136`, `inverse-on-surface #eef1f8`.
- Primario: `primary #484dc4`, `on-primary #ffffff`, `primary-container #6167df`,
  `on-primary-container #fffbff`, `inverse-primary #bfc1ff`, `primary-fixed #e1e0ff`.
- Secundario/terciario (reservados para features futuras, aún no en el CSS):
  `secondary #8338bb`, `on-secondary #ffffff`, `secondary-container #c57afe`,
  `tertiary #5a5c5e`, `on-tertiary #ffffff`.
- Enlace de texto/acento: `accent/link #585ce5`. Divisor/borde: `#ebeef2`.
- Error: `error #ba1a1a`, `on-error #ffffff`, `error-container #ffdad6`.

> *Reconciliación de neutros: el export traía `on-surface #181c21` y `on-surface-variant #464653`
> en su front-matter M3, en conflicto con su propia prosa (`#2D3139` / `#717886`). Para no
> regresar el texto a casi-negro ni cambiar el gris secundario ya verificado en AA, se conservan
> los valores implementados `#2d3139` y `#6b7280` (aprobado por el propietario). Igualmente,
> `surface` del sistema M3 nombra el lienzo; en el CSS `--color-surface` es la tarjeta (`#ffffff`)
> y `--color-background` el lienzo (`#f7f9ff`). El front-matter `colors:` usa el naming del código.

### Elevación y profundidad

- Tarjeta (reposo): `0 18px 45px -10px rgba(25,30,48,0.08), 0 8px 16px -6px rgba(25,30,48,0.03)`;
  borde ultrafino `1px solid rgba(0,0,0,0.04)`.
- Botones de acción: reposo `0 2px 6px rgba(108,114,234,0.15)`; hover `0 8px 18px rgba(108,114,234,0.28)`
  con `translateY(-1.5px)`.
- Avatar: anillo blanco `3px solid #ffffff` con `0 4px 14px rgba(0,0,0,0.08)`.

### Social Icon Bar (tier complementario)

Fila horizontal de botones circulares monocromáticos para canales periféricos. Es la base
de diseño de las **Acciones rápidas** ya implementadas (Celular/Correo) y de QR/Compartir
futuros: fondo translúcido `#f0f2f6`/`surface-container-low`, pasa a blanco sólido con sombra
ambiental en hover; tamaño `40–48px` con bordes circulares (`rounded.full`). En este repo los
controles icon-only son anclas reales con `aria-label` y mínimo táctil ≥44×44.

### Formularios y campos (modales de contacto/suscripción, feature futura)

Relleno gris claro inset `#f4f6f9`, sin contorno duro; foco activo `1.5px solid #6c72ea` con
halo difuso `0 0 0 3px rgba(108,114,234,0.12)`. Reservado para una futura vista modal; no hay
formularios en la Tarjeta estática actual.

## Core Screens

Una sola vista: la Tarjeta digital. Estados:

1. **Perfil → Enlaces → Guardar contacto → Pie** (orden vertical).
2. **Avatar ausente:** círculo con iniciales "FH" en `#484dc4` sobre `#f1f4fa`.

## Open Graph Image (1200×630)

Asset: `assets/og-image.jpg` — JPEG 1200×630, 37 214 bytes, SHA-256
`b7c9b694…a012a2`, generado el 2026-10-23. No es una captura de la página ni una copia del
avatar y no se muestra como `<img>` dentro de la Tarjeta.

Composición (tokens de este documento):

- Lienzo `--color-background` `#f7f9ff` a 1200×630.
- Tarjeta blanca 880×440 centrada, radio 24px, borde `1px solid rgba(0,0,0,0.04)` y la
  sombra histórica de `0 18px 45px -10px rgba(25,30,48,0.08), 0 8px 16px -6px rgba(25,30,48,0.03)`.
- Avatar real 128×128 circular (opcional) a la izquierda.
- Nombre `Fahed Hermoza` a 64px/600 `#2d3139`; Handle `@fahedhermoza` a 30px/400
  `#6b7280`; Tagline `Software Engineer & Speaker & Builder` a 26px/400 `#6b7280`.
- Tipografía Plus Jakarta Sans (o pila del sistema). Sin colores, tipografías ni motivos
  fuera de esta guía.

La aprobación visual de la composición es del propietario; `./init.sh` solo valida que el
JPEG mida 1200×630, no sea una copia del avatar y no exceda 300 KiB.

## Responsive Baseline

Estado verificado (2026-10-23, feature `responsive-baseline`): el layout fluido cubre todo el
rango 320–1280px **sin media queries de ancho**. Los valores ~736 / ~480 / ~360px de este
documento se conservan como **fronteras de auditoría**, no como ramas de implementación.

- Mobile-first; sin scroll horizontal desde 320px hasta 1280px
  (`documentElement.scrollWidth === clientWidth` y `body.scrollWidth === clientWidth`).
- Fórmula única de tarjeta: `width: min(400px, calc(100vw - 2rem))` con `max-width: 100%`,
  dentro de `.page` con gutter `var(--space-gutter)` (16px por lado). Hasta 431px de ancho útil
  la tarjeta ocupa el ancho menos 32px; desde 432px se capa en 400px.
- Botones a ancho completo en todos los tamaños: `width: 100%`, `height: 48px` y
  `box-sizing: border-box`; áreas táctiles de al menos 44×44px (los siete Enlaces miden 48px
  de alto).
- Guard de etiquetas: `.link-button__label` conserva `min-width: 0`, `overflow: hidden`,
  `white-space: nowrap` y `text-overflow: ellipsis`; en la matriz medida la ellipsis no se
  activa (238px disponibles a 320px para etiquetas de ≤95px).
- No se usa `overflow-x: hidden/clip` ni `width: 100vw` como parche: el overflow se corrige,
  no se enmascara. `./init.sh` contiene `Responsive checks:` con siete invariantes.

Mediciones históricas del layout anterior (Chrome DevTools, 2026-10-23; servidor único en
3502, recarga fresca). **No representan el estado local tras `redesign-card-profile`.**

| Viewport | clientWidth | Tarjeta w×h (x) | Botón w×h | Etiquetas truncadas |
| --- | --- | --- | --- | --- |
| 320×844 | 320 | 288×861 (16) | 238×48 | 0 |
| 360×844 | 360 | 328×861 (16) | 278×48 | 0 |
| 375×844 | 375 | 343×841 (16) | 293×48 | 0 |
| 390×844 | 390 | 358×841 (16) | 308×48 | 0 |
| 480×844 | 480 | 400×841 (40) | 350×48 | 0 |
| 736×800 | 721 | 400×841 (160.5) | 350×48 | 0 |
| 768×800 | 753 | 400×841 (176.5) | 350×48 | 0 |
| 1280×800 | 1265 | 400×841 (432.5) | 350×48 | 0 |

A 320–360px el texto del pie ocupa dos líneas y la tarjeta crece a 861px; a 375px o más ocupa
una línea. En los ocho anchos no hay elementos fuera del viewport, el alto extra produce solo
scroll vertical, la consola queda en 0 mensajes y la red sirve documento, CSS, avatar y fuentes
sin `/favicon.ico` ni fallos. La prueba de "sin scroll horizontal" es runtime (ver
`docs/risks-and-open-questions.md`).

Mediciones del Perfil renovado (Chrome DevTools, local en `localhost:3601`, recarga fresca,
2026-11-21):

| Viewport | clientWidth | Tarjeta w×h (x, y) | Botón mínimo w×h | Etiquetas truncadas |
| --- | --- | --- | --- | --- |
| 320×844 | 320 | 288×911 (16, 24) | 238×48 | 0 |
| 360×844 | 360 | 328×911 (16, 24) | 278×48 | 0 |
| 375×844 | 375 | 343×891 (16, 24) | 293×48 | 0 |
| 390×844 | 390 | 358×891 (16, 24) | 308×48 | 0 |
| 480×844 | 480 | 400×891 (40, 24) | 350×48 | 0 |
| 736×800 | 721 | 400×891 (160.5, 24) | 350×48 | 0 |
| 768×800 | 753 | 400×891 (176.5, 24) | 350×48 | 0 |
| 1280×800 | 1265 | 400×891 (432.5, 24) | 350×48 | 0 |

En las ocho anchuras, `documentElement` y `body` tienen `scrollWidth === clientWidth`, los
ocho controles de ancho completo miden 48px de alto (mínimo medido: 238×48px), ningún texto
se recorta y el contenido alto produce solo scroll vertical. A 320px y 360px el pie ocupa dos
líneas. Chrome reportó 0 mensajes en la carga normal y no hubo recursos fallidos; las únicas
capturas de esta implementación son evidencia técnica del implementador, no aprobación visual
del propietario.

Fallback comprobado con fallo inducido del avatar en un contexto aislado a 390×844 y
1280×800: el frame conserva su rectángulo 88×88 y posición, muestra `FH` con `#f1f4fa` /
`#484dc4` y halo blanco de 3px, mantiene el `alt` descriptivo y no genera overflow
horizontal. El único 404 es el recurso de avatar esperado durante esa simulación; tras
restaurar el archivo original, la foto volvió a cargar normalmente.

## Accessibility Baseline

- Contraste mínimo AA en texto y etiquetas de botón.
- Cada botón es un `<a>` real con texto legible; los iconos son decorativos (`aria-hidden`) o con `title`.
- Foco visible (outline de acento) en todos los elementos interactivos.
- `alt` descriptivo en el avatar; `lang="es"` en el documento y `lang="en"` en la Tagline inglesa.
- Respetar `prefers-reduced-motion` desactivando transformaciones y transiciones.
- Controles reales, sin `role="button"` ni manejadores inline; el viewport no deshabilita el zoom.
- `./init.sh` incluye un gate de accesibilidad que no debe debilitarse (ver `CONSTRAINTS.md`).

### Contraste AA de la base (remediación 2026-10-23; rampa re-basada al sistema Stitch 2026-11-22)

Se mantienen las etiquetas e iconos en `#ffffff`. En la adopción del sistema Stitch
(2026-11-22) la rampa se re-basó al matiz periwinkle→orquídea, oscurecido lo justo para
seguir pasando AA (ver *Nota de reconciliación* en la sección de color). Ratios calculados
con la fórmula WCAG 2.x:

| Token | Valor | Blanco en reposo | Blanco con `brightness(1.03)` |
| --- | --- | --- | --- |
| `--color-gradient-1` | `#5c68d4` | 4.79:1 | 4.56:1 |
| `--color-gradient-2` | `#6a64d8` | 4.74:1 | 4.52:1 |
| `--color-gradient-3` | `#765fd4` | 4.82:1 | 4.58:1 |
| `--color-gradient-4` | `#8659d1` | 4.81:1 | 4.57:1 |
| `--color-gradient-5` | `#9654c9` | 4.76:1 | 4.53:1 |
| `--color-on-surface-variant` | `#6b7280` | 4.834:1 sobre `#ffffff` | n/a |
| `--color-primary` sobre `--color-surface-container-low` | `#484dc4` / `#f1f4fa` | 6.082:1 | 6.456:1 |

- El pie no cambia: `--color-on-surface` (`#2d3139`, 13.044:1) y `--color-accent`
  (`#585ce5`, 5.151:1) ya cumplen AA.
- El cambio desplaza cada canal sRGB de los cinco tonos ≈13% hacia abajo, conservando el
  orden lavanda→violeta y la forma, altura y tipografía del botón.
- El margen de hover/foco es obligatorio porque `.link-button:hover` y `:focus-visible`
  aplican `filter: brightness(1.03)`; cualquier token nuevo debe recalcular ambos estados
  y actualizar el gate de `./init.sh`.

## Do's and Don'ts

- **Sí:** usar los tokens de color y la escala tipográfica de este documento.
- **Sí:** mantener una sola columna y botones de ancho completo.
- **Sí:** asegurar contraste y foco visible.
- **No:** introducir nuevas tipografías, colores fuera de la paleta o iconos con relleno de color distinto al blanco.
- **No:** añadir carruseles, animaciones llamativas ni más de una vista.
- **No:** usar el Carrd Template como especificación pixel-perfect.

## Open Design Questions

- ~~Tratamiento final del botón "Guardar contacto" (neutro vs dentro del degradado).~~ **Resuelto (2026-10-23, `save-contact-vcard`):** misma forma que un Enlace con tratamiento neutro `#f1f4fa`/`#484dc4`, fuera de la rampa, entre los Enlaces y el pie.
- ~~Cómo se repite/extiende el degradado de 5 tonos para 8 botones.~~ **Resuelto (2026-10-23, `links-order-gradient`):** los 7 Enlaces usan los cinco tonos más dos intermedios 50/50; "Guardar contacto" queda neutro y fuera de la rampa.
- ~~Diseño definitivo de `assets/og-image.jpg`.~~ **Resuelto (2026-10-23, `deploy-cloudflare-pages`):** JPEG 1200×630 con la composición de la sección "Open Graph Image"; aprobada por el propietario el 2026-10-23.
- ¿Se necesita favicon y `theme-color`? (fuera del MVP por ahora).

## Dirección del rediseño acordado (2026-11-21)

Los tokens base y las mediciones históricas describen la Tarjeta publicada. Esta sección
se ejecuta en slices: `redesign-card-profile` está implementado localmente en esta worktree,
pero aún requiere revisión visual del propietario y validación independiente; no se ha
publicado. Los cambios de Acciones rápidas, Enlaces, pie, QR, Compartir e imagen social
siguen siendo features posteriores. La dirección partió de dos capturas aportadas por Fahed
el 2026-11-21 (Tarjeta completa y Vista QR superpuesta); no están versionadas ni disponibles
en el repositorio para comparación visual en esta sesión, y el `code.html`/`DESIGN.md`
adjuntos son referencias parciales que no deben copiarse literalmente.

### Jerarquía y composición objetivo

- Lienzo muy claro y tarjeta blanca centrada, con mayor aire, esquinas más redondeadas y
  sombra suave. Conservar una sola columna fluida y márgenes seguros en móvil.
- Encabezado con rótulo «NFC CONNECT», avatar local, nombre prominente, Handle, Tagline
  espaciada y punto verde ornamental. El rótulo y el punto no anuncian conexión activa ni
  estado «En línea» a tecnologías de asistencia. No usar la foto remota del prototipo.
- Fila de cuatro Acciones rápidas: Celular, Correo, Código QR y una única acción Compartir.
  Los controles tendrán nombre accesible, foco visible y área táctil de al menos 44×44 px;
  los 40×40 px del prototipo no son el objetivo final.
- Cinco Enlaces grandes, en orden Instagram, Facebook, WhatsApp, LinkedIn y Portafolio,
  conservan la secuencia visual lavanda→violeta. Celular y Correo salen de esa pila sin
  perder sus destinos ni sus datos en la vCard.
- Pie con la invitación «¿Tienes un proyecto en mente? Haz clic en mis redes o escríbeme
  directamente», donde el texto final enlaza a WhatsApp; Guardar contacto se presenta como
  acción visual discreta y sigue descargando la vCard estática; cerrar con «Tarjeta NFC & QR».

### Vista QR y estados de interacción

- Al activar QR, mostrar un cuadro centrado sobre la Tarjeta con fondo atenuado, título,
  QR escaneable de la URL pública, cerrar, «Copiar Enlace» y «Guardar PNG». Su tamaño debe
  seguir siendo utilizable en un móvil estrecho. El cierre devuelve la atención al punto
  de apertura y el cuadro conserva navegación por teclado y lectura accesible.
- Compartir usa la hoja nativa del dispositivo cuando existe. Si no está disponible,
  copia la URL canónica y muestra confirmación visible. La copia desde la Vista QR usa la
  misma URL. Definir una respuesta comprensible cuando el portapapeles no permita copiar.
- Mantener `prefers-reduced-motion`, estados de foco visibles y contrastes AA en reposo y
  hover/foco. Los colores claros de las referencias son dirección cromática: sus valores
  exactos no son aprobados como tokens porque varios fallan AA con texto blanco.

### Tipografía, assets y límites

- Conservar Plus Jakarta Sans y los SVG propios. Ajustar pesos, tamaños, espaciado y
  geometría hacia las capturas; no adoptar Inter, Font Awesome ni Tailwind CDN.
- Conservar la imagen de perfil local y el archivo `assets/fahedhermoza.vcf`; no generar la
  vCard mediante Blob. La imagen social se rediseñará para acompañar la nueva Tarjeta,
  seguirá siendo JPEG 1200×630 y necesitará aprobación visual de Fahed antes de publicar.
- El QR descargable debe ser PNG y codificar exactamente
  `https://fahed-hermoza-card.fahedhermoza.workers.dev/`. El sitio sigue siendo estático,
  sin backend ni build; se admite JavaScript mínimo solo para las nuevas interacciones.

**Criterio visual:** las capturas orientan jerarquía y sensación general, no una réplica
pixel a pixel. Una revisión de Fahed en móvil y escritorio decide la aceptación visual;
el contraste, la geometría responsive y la accesibilidad mantienen sus gates técnicos.

### Acciones rápidas y Enlaces grandes — slice implementado (`redesign-contact-navigation`, 2026-11-21)

Este slice ejecuta la parte de navegación de la dirección anterior. Decisiones fijadas
(el propietario aprueba visualmente por separado; aún `pending`):

- **Cinco Enlaces grandes** en `<nav class="links">`, en orden Instagram, Facebook,
  WhatsApp, LinkedIn, Portafolio, con los tonos `--gradient-1`, `-2`, `-3`, `-3-4`, `-4`
  (rampa lavanda→violeta, etiqueta e icono blancos, 48px de alto, ancho completo). Las
  reglas `.link-button--gradient-5` y `--gradient-4-5` (incluida su interpolación
  `color-mix`/`@supports`) se conservan en `styles.css` como parte del sistema de tonos
  aunque ya no las use ningún Enlace; no son colores nuevos.
- **Fila «Acciones rápidas»** (`<nav class="quick-actions" aria-label="Acciones rápidas">`)
  ubicada **entre el encabezado de identidad y la lista de Enlaces**. En este slice hospeda
  **solo dos** controles: Celular (`tel:+51955116562`) y Correo
  (`mailto:fahedhermoza@gmail.com`). QR y Compartir son features posteriores
  (`redesign-qr-panel`, `redesign-share-action`) que añadirán más círculos a la misma fila.
- **Tono de las Acciones rápidas (decisión de diseño, vía neutra):** botones circulares
  **solo-icono** con superficie neutra clara `--color-surface-container-low` (#f1f4fa) e
  icono oscuro `--color-primary` (#484dc4) — el mismo par neutro pineado de Guardar
  contacto (6.082:1 en reposo, 6.456:1 con `brightness(1.03)`), ya cubierto por el gate de
  contraste 15/15. **No** usan el degradado lavanda→violeta ni tokens nuevos.
- Cada círculo es un `<a>` real con su destino canónico y nombre accesible vía
  `aria-label` («Celular: llamar al +51 955 116 562» / «Correo a fahedhermoza@gmail.com»);
  el SVG es decorativo (`aria-hidden="true"` + `focusable="false"`). Diámetro 48px
  (área táctil ≥44×44), `:focus-visible` con `outline: 2px solid var(--color-accent)` y
  `outline-offset: 2px`, hover `brightness(1.03)` y `prefers-reduced-motion` que anula
  `transition`/`transform`.
- El encabezado ornamental, el botón Guardar contacto y el pie actual quedan **sin cambios**
  en este slice (el pie se rediseña en `redesign-footer-contact`). La duplicación transitoria
  de Correo (Acciones rápidas + pie) es aceptable aquí y se resolverá entonces.
