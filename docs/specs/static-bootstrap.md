# Feature Implementation Spec: Sitio estático arrancable localmente

## Source Feature

- `id`: `static-bootstrap`
- `area`: `bootstrap`
- `depends_on`: `[]`
- `status`: `not_started`
- `source`: `feature_list.json`

## Goal

Establecer el esqueleto mínimo del sitio estático de la Tarjeta digital: un `index.html` válido en la raíz del repositorio, sin build, sin bundler y sin dependencias externas, que se pueda abrir directamente o servir por HTTP y que el harness pueda verificar de forma no bloqueante. Esta feature deja el repositorio listo (`estado bootstrapped`) para que las features de diseño, layout y contenido se apoyen en un documento real en lugar de crear la superficie desde cero.

El alcance termina cuando existe un documento HTML5 semántico, en español y móvil-first por viewport, y `./init.sh` ejecuta una comprobación no bloqueante que confirma ese estado.

## Non-Goals

- No implementar el Perfil, la lista de Enlaces, el botón "Guardar contacto", el pie ni los metadatos Open Graph (features posteriores).
- No introducir tokens visuales, tipografía ni estilos del sistema "Serene Bio Card" (`design-tokens` y `page-shell` son features separadas).
- No agregar JavaScript, Google Fonts, paquetes npm, frameworks, bundlers ni paso de build.
- No configurar el despliegue en Cloudflare Pages ni crear `assets/og-image.jpg` (features/riesgos posteriores).
- No modificar los documentos de discovery ni `DESIGN.md`.

## Job Story

When un implementador necesita empezar a construir la Tarjeta digital,
I want to tener un `index.html` real y servible con una comprobación automática de arranque,
so I can iterar en contenido y diseño sin crear infraestructura base en cada feature.

## Users And Permissions

- Implementador/agente: crea `index.html` y ajusta `init.sh`; no toca contenido de producto final.
- Visitante (indirecto): aún no consume contenido; solo se garantiza que el documento carga sin errores.
- No aplica autenticación, roles ni permisos (`docs/technical-discovery.md`).

## Acceptance Scenarios

### Scenario 1: Bootstrap detectado y verificable

Given un repositorio sin `index.html`,
When el implementador crea `index.html` y ejecuta `./init.sh`,
Then el script reporta `Harness status: bootstrapped` y sus comprobaciones no bloqueantes terminan con código de salida `0`.

### Scenario 2: Documento servible en navegador móvil

Given `index.html` en la raíz del repositorio,
When se sirve con `python3 -m http.server 8080 --directory .` y se abre `http://localhost:8080`,
Then el navegador renderiza un documento HTML5 sin errores de consola y sin peticiones fallidas para la página.

### Scenario 3: Base incompleta detectada

Given un `index.html` al que le falta `lang="es"`, `<title>` o el meta viewport,
When se ejecuta `./init.sh`,
Then el script falla (código distinto de `0`) e imprime qué comprobación faltó, sin iniciar un servidor.

## Repository Research

### Files Inspected

- `AGENTS.md` — workflow de arranque, reglas y Definition of Done.
- `PROGRESS.md` — estado actual: pre-bootstrap; siguiente feature `static-bootstrap`.
- `feature_list.json` — metadata y verificación de `static-bootstrap`.
- `init.sh` — gate estándar actual; detecta `index.html` y reporta `pre-bootstrap`/`bootstrapped`.
- `docs/technical-discovery.md` — stack sin build, salida desde la raíz del repositorio.
- `docs/build-brief.md` — contenido esperado del MVP (contexto, fuera de este slice).
- `docs/domain-model.md` — estados de publicación de la Tarjeta digital (borrador/publicada).
- `DESIGN.md` — sistema visual de referencia (se usa en features posteriores).
- `CONTEXT.md` — vocabulario del dominio.
- `assets/avatar.jpg` — asset existente; no se usa todavía.
- `git status`/`git ls-files` — no existe `index.html` ni scaffolding de app; el repo solo tiene docs, skills y harness.

### Existing Patterns To Follow

- Sitio estático sin build: la salida es la raíz del repositorio (`docs/technical-discovery.md`).
- Estilos futuros vía CSS moderno con custom properties; sin frameworks (`docs/technical-discovery.md`).
- `init.sh` ya usa `set -euo pipefail`, resuelve rutas relativas al cwd y separa verificación de servicio (modo `RUN_SERVE_COMMAND`).
- El harness exige que `init.sh` no arranque servidores de larga duración por defecto.

### Current Gaps

- No existe `index.html`.
- No hay framework de tests, linter ni comando E2E; la verificación del MVP es manual en iOS/Android y navegador (`docs/technical-discovery.md`).
- `init.sh` hoy solo comprueba existencia de `index.html`; no valida su contenido mínimo.
- `python3` está disponible en el entorno (`/opt/homebrew/bin/python3`, versión 3.14.4).

## Technical Approach

1. Crear `index.html` en la raíz del repositorio, autocontenido:
   - `<!DOCTYPE html>`.
   - `<html lang="es">`.
   - `<head>` con `<meta charset="utf-8">`, `<meta name="viewport" content="width=device-width, initial-scale=1">` y un `<title>` provisional en español (p. ej. `Fahed Hermoza — Tarjeta digital`).
   - `<body>` con un contenedor semántico `<main>` vacío como punto de montaje para features posteriores; sin estilos propios, sin fuentes externas y sin JavaScript.
2. Ajustar `init.sh` para que, además de la detección, ejecute comprobaciones no bloqueantes sobre `index.html`: que exista, que contenga `lang="es"`, un `<title>` no vacío y el meta viewport. Debe imprimir cada verificación y salir con error claro si falla; debe seguir sin iniciar un servidor por defecto (mantener el modo `RUN_SERVE_COMMAND=1` solo como opción manual).
3. Registrar la evidencia y cerrar la feature actualizando `feature_list.json` y `PROGRESS.md`.

Mantener la simplicidad: no se decide aquí la estructura visual ni el contenido; solo se garantiza un documento base válido y verificable.

## Expected File Changes

- `index.html` — crear; documento HTML5 mínimo, sin dependencias, punto de partida del sitio.
- `init.sh` — modificar; añadir el gate no bloqueante que valida el bootstrap.
- `feature_list.json` — modificar; marcar `static-bootstrap` y registrar evidencia (lo hace el implementador).
- `PROGRESS.md` — modificar; actualizar estado verificado y bitácora de sesión (lo hace el implementador).
- `docs/specs/static-bootstrap.md` — crear; este spec.

## Visual Design Impact

- UI involved: yes (mínima).
- Design source: `DESIGN.md` (referencia, pero no se aplica todavía).
- Screens or states affected: una sola vista, estado "documento vacío renderizado con estilos por defecto".
- New design artifact required: no — `design-tokens` y `page-shell` definirán el sistema visual y el layout.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — el stack estático y la salida desde la raíz ya están en `docs/technical-discovery.md`; no se crean nuevas capas ni boundaries.
- `CONSTRAINTS.md`: not needed — no introduce reglas MUST/MUST NOT nuevas más allá de las ya documentadas (sin build, sin dependencias).
- `AGENTS.md`: not needed — el workflow de arranque (`./init.sh`) y las reglas no cambian.
- Other docs: `docs/technical-discovery.md` — not needed; descriptor de comandos ya documentado y esta feature no cambia la fuente de verdad.

## Implementation Plan

1. Crear `index.html` con la estructura mínima descrita.
2. Actualizar `init.sh` para ejecutar las comprobaciones no bloqueantes de bootstrap y mantener el modo de servicio manual.
3. Ejecutar `./init.sh` y confirmar salida `0`; servir la página y verificar la carga en viewport móvil.
4. Actualizar `feature_list.json` (status y evidencia) y `PROGRESS.md`.

## Implementation Tasks

- [ ] Crear `index.html` en la raíz con `lang="es"`, charset, viewport y `<title>`.
- [ ] Añadir un `<main>` vacío como punto de montaje, sin estilos ni scripts.
- [ ] Actualizar `init.sh` con comprobaciones no bloqueantes de existencia, `lang="es"`, `<title>` y viewport.
- [ ] Confirmar que `./init.sh` no inicia servidores por defecto y sale `0` con el bootstrap correcto.
- [ ] Verificar manualmente el render servido en viewport móvil (320/375px) sin errores de consola.
- [ ] Registrar evidencia en `feature_list.json` y actualizar `PROGRESS.md`.

## Verification Plan

- `./init.sh` — debe reportar `Harness status: bootstrapped` y terminar con código `0`; no debe iniciar procesos de larga duración.
- Prueba negativa: retirar temporalmente `lang="es"` del HTML y confirmar que `./init.sh` falla con mensaje claro; restaurar después.
- `python3 -m http.server 8080 --directory .` y abrir `http://localhost:8080` en viewports 320px, 375px y escritorio; confirmar documento válido, sin scroll horizontal y sin errores en consola.
- Comprobación E2E: no aplica; el repositorio no tiene harness E2E ni framework de tests. La verificación es script no bloqueante + comprobación manual en navegador, coherente con `docs/technical-discovery.md`.
- `init.sh`: debe ejecutar las comprobaciones anteriores (gate estándar), imprimir los comandos de servicio como seguimiento manual y no arrancar el servidor salvo `RUN_SERVE_COMMAND=1`.

## Evidence To Capture

- Salida de `./init.sh` en estado bootstrapped (código `0`).
- Salida de `./init.sh` en la prueba negativa (fallo esperado).
- Resultado manual de carga en navegador móvil (320/375px) sin errores de consola.
- Referencias actualizadas en `feature_list.json` (`status`, `evidence`) y `PROGRESS.md`.

## Validator Checklist

- [ ] Implementation stays within this feature's scope.
- [ ] Acceptance scenarios pass.
- [ ] Verification evidence is present.
- [ ] Persistent E2E coverage was added/updated when the feature has an observable user/API flow and an E2E harness exists, or the spec explains why it is not needed.
- [ ] `feature_list.json` and `PROGRESS.md` were updated correctly.
- [ ] No unrelated product behavior or extra feature work was added.
