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
      status: pending
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
  gradient-1: '#5a67d1'
  gradient-2: '#645fcc'
  gradient-3: '#705aca'
  gradient-4: '#8055c8'
  gradient-5: '#9252c5'
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
    rounded: '{rounded.xl}'
    shadow: '0 18px 45px -10px rgba(25,30,48,0.08), 0 8px 16px -6px rgba(25,30,48,0.03)'
    border: '1px solid rgba(0,0,0,0.04)'
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
- **`assets/og-image.jpg`** — imagen Open Graph 1200×630. Estado: pendiente de crear.

Autoridad: los tokens, reglas de layout y guía de componentes de este documento son la fuente de verdad cuando el template o las imágenes entren en conflicto.

## Generated Concept Images

Ninguna. Este agente no puede generar ni leer imágenes, así que no se produjeron conceptos. La `og-image` se creará con otra herramienta.

## Product Feel

Minimalismo cálido y etéreo. Mucho aire, geometría refinada, autoridad tipográfica discreta y microinteracciones suaves. Nada de ruido digital ni bordes duros.

## Colors

- **Fondo (canvas):** `#f7f9ff` — off-white frío suave que da contraste a la tarjeta.
- **Superficie (tarjeta):** `#ffffff` — contenedor limpio.
- **Borde / divisores:** `#ebeef2` — reglas finas, sin estructura agresiva.
- **Texto principal:** `#2d3139` — gris pizarra profundo, no negro puro.
- **Texto secundario / meta:** `#6b7280` — para handle y tagline; el pie usa `#2d3139`.
- **Acento / enlaces:** `#585ce5`.
- **Degradado de botones** (secuencia descendente en la pila de Enlaces):
  1. `#5a67d1`
  2. `#645fcc`
  3. `#705aca`
  4. `#8055c8`
  5. `#9252c5`
  El texto y el icono de todos los botones van siempre en `#ffffff`.

Con 7 Enlaces, la progresión se resuelve recorriendo los cinco tonos e insertando dos intermedios 50/50 en los saltos mayores (3→4 y 4→5), sin repetir tonos ni superar 14/255 por canal entre botones consecutivos:

1. Instagram — `gradient-1` `#5a67d1`
2. Facebook — `gradient-2` `#645fcc`
3. WhatsApp — `gradient-3` `#705aca`
4. LinkedIn — intermedio `gradient-3`/`gradient-4` ≈ `#7858c9`
5. Portafolio — `gradient-4` `#8055c8`
6. Correo — intermedio `gradient-4`/`gradient-5` ≈ `#8954c6`
7. Celular — `gradient-5` `#9252c5`

Los intermedios se derivan con `color-mix` a partir de los tokens existentes (con fallback al tono inferior). No se añaden colores ni tokens. El botón "Guardar contacto" queda fuera de la rampa con tratamiento neutro (superficie `#f1f4fa` con texto `#484dc4`) para diferenciarse de los Enlaces externos.

## Typography

Familia única **Plus Jakarta Sans**, con pila de respaldo del sistema (`system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`).

- **Nombre / Handle:** `headline-lg`, peso 600, tracking negativo sutil.
- **Tagline:** `body-md`, color `#6b7280`.
- **Etiquetas de botón:** `button-label` en mayúsculas, tracking `0.18em`, peso 800.
- **Pie / meta:** `body-sm` o `body-md` con enlaces en `#585ce5` subrayados.

## Layout

- Tarjeta única centrada vertical y horizontalmente en escritorio; con márgenes seguros en móvil.
- Ancho máximo de tarjeta: 380–420px en escritorio; `calc(100vw - 2rem)` en móvil.
- Columna única. Bloques separados por divisores de 1px a ancho completo de la tarjeta.
- Perfil con margen `space-xl` arriba y abajo; botones con separación vertical `space-sm` (0.75rem); pie con `space-lg`.

## Shapes

- Tarjeta: esquinas `12–16px` (`rounded.xl`).
- Botones: `6–8px` (`rounded.md`), forma estructurada tipo pill suave.
- Avatar: círculo perfecto con anillo blanco de 3px.
- Badges / chips secundarios: `6px`.

## Components

- **Perfil:** avatar circular 88×88 con `object-fit: cover` y halo blanco; nombre en `headline-lg` a 1.25rem del avatar; handle y tagline debajo.
- **Botón de Enlace:** ancho completo, alto 48px, padding horizontal 1.25rem, flexbox `space-between` (etiqueta mayúsculas a la izquierda, icono SVG 18px a la derecha), fondo del degradado, sombra `0 2px 6px rgba(108,114,234,0.15)`. Hover/focus: `translateY(-1.5px)`, sombra `0 8px 18px rgba(108,114,234,0.28)`, `filter: brightness(1.03)`. Transición 180ms ease.
- **Guardar contacto:** misma forma que un Enlace (`width: 100%`, 48px, padding horizontal 1.25rem, radio `rounded.md`, flexbox `space-between`, etiqueta `button-label` en mayúsculas e icono SVG 18px a la derecha), pero fuera de la rampa: fondo `#f1f4fa` (`surface-container-low`) y texto/icono `#484dc4` (`primary`). Sombra base `0 2px 6px rgba(25,30,48,0.08)`; hover/focus `translateY(-1.5px)`, sombra `0 8px 18px rgba(25,30,48,0.12)`, `filter: brightness(1.03)` y outline de acento 2px/offset 2px. Dispara la descarga de `assets/fahedhermoza.vcf` con un `<a download>`, sin JavaScript. Se separa del último Enlace con `space-sm` (12px) y del pie con el margen propio del pie.
- **Pie:** borde superior `1px #ebeef2`, texto centrado, correo y handle con enlaces acentuados.

## Core Screens

Una sola vista: la Tarjeta digital. Estados:

1. **Perfil → Enlaces → Guardar contacto → Pie** (orden vertical).
2. **Avatar ausente:** círculo con iniciales "FH" en `#484dc4` sobre `#f1f4fa`.

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

Mediciones clave (Chrome DevTools, servidor único en 3502, recarga fresca):

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

## Accessibility Baseline

- Contraste mínimo AA en texto y etiquetas de botón.
- Cada botón es un `<a>` real con texto legible; los iconos son decorativos (`aria-hidden`) o con `title`.
- Foco visible (outline de acento) en todos los elementos interactivos.
- `alt` descriptivo en el avatar; `lang="es"` en el documento y `lang="en"` en la Tagline inglesa.
- Respetar `prefers-reduced-motion` desactivando transformaciones y transiciones.
- Controles reales, sin `role="button"` ni manejadores inline; el viewport no deshabilita el zoom.
- `./init.sh` incluye un gate de accesibilidad que no debe debilitarse (ver `CONSTRAINTS.md`).

### Contraste AA de la base (remediación 2026-10-23)

Se mantienen las etiquetas e iconos en `#ffffff`; solo se oscurecieron los fondos de los
cinco tonos y el token de texto secundario. Ratios calculados con la fórmula WCAG 2.x:

| Token | Valor | Blanco en reposo | Blanco con `brightness(1.03)` |
| --- | --- | --- | --- |
| `--color-gradient-1` | `#5a67d1` | 4.889:1 | 4.658:1 |
| `--color-gradient-2` | `#645fcc` | 5.184:1 | 4.936:1 |
| `--color-gradient-3` | `#705aca` | 5.244:1 | 4.993:1 |
| `--color-gradient-4` | `#8055c8` | 5.184:1 | 4.920:1 |
| `--color-gradient-5` | `#9252c5` | 4.958:1 | 4.743:1 |
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
- Diseño definitivo de `assets/og-image.jpg`.
- ¿Se necesita favicon y `theme-color`? (fuera del MVP por ahora).
