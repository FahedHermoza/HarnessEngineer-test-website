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
  on-surface-variant: '#717886'
  outline: '#767685'
  primary: '#484dc4'
  on-primary: '#ffffff'
  accent: '#585ce5'
  gradient-1: '#6876f0'
  gradient-2: '#736deb'
  gradient-3: '#8168e8'
  gradient-4: '#9362e6'
  gradient-5: '#a85ee2'
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
- **Texto secundario / meta:** `#717886` — para handle, tagline y pie.
- **Acento / enlaces:** `#585ce5`.
- **Degradado de botones** (secuencia descendente en la pila de Enlaces):
  1. `#6876f0`
  2. `#736deb`
  3. `#8168e8`
  4. `#9362e6`
  5. `#a85ee2`
  El texto y el icono de todos los botones van siempre en `#ffffff`.

Con 7 Enlaces + "Guardar contacto" (8 botones), la progresión de 5 tonos se repite o se interpola suavemente; el botón "Guardar contacto" puede usar un tratamiento neutro (superficie `#f1f4fa` con texto `#484dc4`) para diferenciarse de los Enlaces externos.

## Typography

Familia única **Plus Jakarta Sans**, con pila de respaldo del sistema (`system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`).

- **Nombre / Handle:** `headline-lg`, peso 600, tracking negativo sutil.
- **Tagline:** `body-md`, color `#717886`.
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
- **Guardar contacto:** misma forma que un Enlace, tratamiento neutro; dispara la descarga de la vCard.
- **Pie:** borde superior `1px #ebeef2`, texto centrado, correo y handle con enlaces acentuados.

## Core Screens

Una sola vista: la Tarjeta digital. Estados:

1. **Perfil → Enlaces → Guardar contacto → Pie** (orden vertical).
2. **Avatar ausente:** círculo con iniciales "FH" en `#484dc4` sobre `#f1f4fa`.

## Responsive Baseline

- Mobile-first; sin scroll horizontal desde 320px.
- Botones a ancho completo en todos los tamaños.
- Áreas táctiles de al menos 44×44px (los botones de 48px cumplen).
- Ajustes de tamaño tipográfico y márgenes en breakpoints ~736px, ~480px y ~360px, siguiendo la escala del template.

## Accessibility Baseline

- Contraste mínimo AA en texto y etiquetas de botón.
- Cada botón es un `<a>` real con texto legible; los iconos son decorativos (`aria-hidden`) o con `title`.
- Foco visible (outline de acento) en todos los elementos interactivos.
- `alt` descriptivo en el avatar; `lang="es"` en el documento.
- Respetar `prefers-reduced-motion` desactivando transformaciones y transiciones.

## Do's and Don'ts

- **Sí:** usar los tokens de color y la escala tipográfica de este documento.
- **Sí:** mantener una sola columna y botones de ancho completo.
- **Sí:** asegurar contraste y foco visible.
- **No:** introducir nuevas tipografías, colores fuera de la paleta o iconos con relleno de color distinto al blanco.
- **No:** añadir carruseles, animaciones llamativas ni más de una vista.
- **No:** usar el Carrd Template como especificación pixel-perfect.

## Open Design Questions

- Tratamiento final del botón "Guardar contacto" (neutro vs dentro del degradado).
- Cómo se repite/extiende el degradado de 5 tonos para 8 botones.
- Diseño definitivo de `assets/og-image.jpg`.
- ¿Se necesita favicon y `theme-color`? (fuera del MVP por ahora).
