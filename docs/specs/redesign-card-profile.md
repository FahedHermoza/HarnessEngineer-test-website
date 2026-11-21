# Feature Implementation Spec: Nueva estructura visual del Perfil

## Source Feature

- `id`: `redesign-card-profile`; `area`: `profile`; `status`: `not_started` al planificar.
- `depends_on`: `profile-identity`, `avatar-fallback`, `accessibility-baseline`, `responsive-baseline` (todos `accepted`).
- `source`: `feature_list.json` (entrada `redesign-card-profile`, verificación y notas); `DESIGN.md` § «Dirección del próximo rediseño».

## Goal

Renovar únicamente el lienzo, la tarjeta y el encabezado del Perfil: más aire, tarjeta blanca más suave, rótulo visual «NFC CONNECT», avatar **local** con fallback «FH», Nombre «Fahed Hermoza», Handle «@fahedhermoza», Tagline «Software Engineer & Speaker & Builder» y punto verde ornamental. Las capturas del propietario son dirección, no una especificación pixel-perfect ni aprobación del resultado implementado.

Conservar en este slice los siete Enlaces actuales, Guardar contacto, pie y metadatos sin cambiar destinos ni contratos; las Acciones rápidas, el nuevo pie, QR, Compartir y la imagen social pertenecen a features posteriores.

## Non-Goals

- No mover Celular/Correo a una fila rápida ni reducir los siete `.link-button` a cinco (`redesign-contact-navigation`). No añadir controles QR/Compartir, popover, QR PNG ni JS nuevo.
- No cambiar el pie, la presentación/archivo de la vCard ni `assets/og-image.jpg`/metadatos de producción (`redesign-footer-contact`, `redesign-social-preview`).
- No copiar `code.html` externo ni importar Inter, Tailwind CDN, Font Awesome, avatar remoto, framework, build o dependencias. No alterar la URL pública ni desplegar.
- No resolver en este slice las tareas operativas de redirección HTTP→HTTPS ni exposición de archivos internos de Workers.

## Job Story / Users And Permissions

When un visitante abre la Tarjeta digital en móvil o escritorio, I want to reconocer enseguida a Fahed en un Perfil claro y agradable, so I can elegir un canal de contacto con confianza. Página pública sin login ni roles; el propietario decide la aprobación visual, no el implementador ni la auditoría automática.

## Acceptance Scenarios

1. **Perfil normal.** Given página cargada a 390×844 o 1280×800, When se muestra la tarjeta, Then se ven lienzo claro, tarjeta blanca suavizada, «NFC CONNECT», avatar local, Nombre, Handle, Tagline y punto verde; existe un solo `h1`, se conserva `lang="en"` en la Tagline y el retrato tiene `alt` descriptivo. No hay texto o atributo «En línea»/«conectado» que finja presencia o NFC activo.
2. **Semántica ornamental.** Given el árbol de accesibilidad, When se inspeccionan el rótulo y el punto, Then no se anuncian como estado, control o conexión activa; el punto se oculta de tecnología asistiva, y el rótulo ornamental no roba el nombre del `h1` (si es puramente ornamental, `aria-hidden="true"`). No añadir `role="status"`, `aria-live`, `title` o `aria-label` de presencia.
3. **Avatar ausente.** Given una simulación aislada de fallo del avatar con caché limpia, When falla `assets/avatar.jpg`, Then aparecen «FH» en un círculo del mismo tamaño y posición, sin salto de layout ni scroll horizontal; el `alt` de la imagen sigue presente y el fallback es ornamental. Tras restaurar el asset y recargar, vuelve la foto. El 404 inducido en esta prueba se documenta como esperado, no se atribuye a la carga normal.
4. **Regresión de contenido.** Given el diff y página servida, When se revisan los controles, Then existen los siete destinos exactos (Instagram, Facebook, WhatsApp, LinkedIn, Portafolio, Correo y Celular), el ancla de vCard `href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf"`, los dos enlaces del pie y los `canonical`/`og:url`/imágenes actuales sin alteraciones. No hay nuevo control inerte.
5. **AA y responsive.** Given la matriz 320/360/375/390/480/736/768/1280 CSS px, When se carga con el alto estándar (844 móvil, 800 escritorio), Then ambos `scrollWidth === clientWidth`, textos sin recorte, botones ≥44×44 y solo scroll vertical si la tarjeta es alta. Foco y reduced motion existentes siguen funcionando; texto e iconos cumplen ≥4.5:1 en estados aplicables y Lighthouse móvil Accessibility ≥95, sin hallazgos `critical`/`serious`.
6. **Gate y aprobación.** Given código implementado, When se ejecuta `bash -n init.sh && ./init.sh`, Then sale 0 sin arrancar servidor y pasan `Accessibility checks:` y `Responsive checks:` sin debilitarse; una mutación del rótulo ornamental o pérdida del fallback falla en copia temporal. La revisión visual del propietario contra sus capturas en móvil **y** escritorio se solicita y registra por separado: ninguna ejecución técnica constituye su aprobación.

## Repository Research

### Files Inspected

- `AGENTS.md`, `PROGRESS.md`, `feature_list.json` — reglas AA, estado y verificación de la feature; arranque del orquestador reportado: `./init.sh` exit 0 y git limpio, no repetido por este planner.
- `CONTEXT.md`, `docs/build-brief.md`, `docs/domain-model.md`, `docs/risks-and-open-questions.md` — vocabulario, contenido, límites del rediseño y referencias visuales externas no versionadas.
- `DESIGN.md` — tokens vigentes y dirección 2026-11-21; sección histórica de mediciones representa el diseño anterior.
- `CONSTRAINTS.md`, `docs/technical-discovery.md` — AA, responsive, vCard, metadatos y stack sin E2E persistente.
- `index.html`, `styles.css`, `init.sh` — estructura y contratos textuales actuales (perfil en dos headers dentro de `.card`; avatar/fallback de 88px; 51 tokens; `init.sh` fija ancho de tarjeta, tamaños de avatar, padding de identidad, 10 anclas, 8 SVG y contrastes calculados).
- `.agents/skills/feature-spec/references/spec-template.md`, `docs/specs/profile-identity.md` — plantilla y patrón de spec; `ARCHITECTURE.md` no existe.

### Existing Patterns And Gaps

- Sitio de una vista en HTML/CSS, fuentes Google Plus Jakarta Sans con fallback; SVG inline, solo `onerror` mínimo del avatar. No `package.json`, runner E2E ni servidor iniciado por defecto.
- `.page` centra `.card`, fórmula de ancho `min(400px, calc(100vw - 2rem))`, `max-width:100%`, gutter 16px; los checkers usan extracción textual de reglas. Preservar fórmulas responsive y estructura que comprueban `init.sh` o actualizar su contrato explícitamente junto con `DESIGN.md`/`CONSTRAINTS.md`, **nunca** quitar el gate para hacerlo pasar.
- El rótulo y punto aún no existen. Las capturas y adjuntos originales de 2026-11-21 **no están en el repo**; pedirlos al propietario para comparación visual. No hay evidencia de aprobación visual del nuevo diseño ni pruebas de dispositivo de este slice.

## Technical Approach

1. Conservar `<main class="page"><article class="card">` y la lista, descarga, pie y `<head>` actuales. Introducir rótulo y punto como elementos no interactivos dentro del área del Perfil, fuera de anclas y fuera del `h1`. Mantener el nombre/handle/tagline exactos, `lang="en"` y `<img src="assets/avatar.jpg" alt="Retrato de Fahed Hermoza">` con el `onerror`/fallback «FH». Se pueden agrupar visualmente los dos headers actuales **sin romper** el extractor de `PROFILE_BLOCK` de `init.sh`; si se cambia su estructura, adaptar el extractor y sus tests de manera explícita.
2. Afinar `body`/`.page`/`.card` y `.profile*` en `styles.css` con espacio, esquinas, sombra y jerarquía coherentes con `DESIGN.md`. No inferir valores CSS exactos de capturas ausentes. Preferir conservar los 51 tokens y los tokens de contraste fijados; documentar valores nuevos de geometría en `DESIGN.md` y, si se alteran tokens, sincronizar `styles.css`, `DESIGN.md`, `CONSTRAINTS.md` e `init.sh` con ratios calculados en reposo y estados activos. No cambiar gradientes de Enlaces o fondo/texto neutro si no es necesario para este Perfil.
3. Puntito ornamental verde: elegir un color documentado en `DESIGN.md`, sin comunicar estado mediante texto/semántica, y verificar contraste si se usa como indicador significativo (preferencia: puramente decorativo). El rótulo es visible pero no indicador funcional; no añadir acción NFC. Mantener ancho fluido, `max-width:100%` y sin máscaras de overflow; cambios de altura no deben recortar la tarjeta en viewport corto. Conservar focus y reduced motion en controles existentes.
4. Añadir checks positivos/negativos específicos del nuevo Perfil a `init.sh`; si cambian reglas históricas de padding/avatar/shape, sustituir solo las aserciones obsoletas con comprobaciones equivalentes o más fuertes. Preservar íntegros `Accessibility checks:` (10 anclas/7 botones/8 SVG, `alt`, `lang`, contraste calculado, foco, reduced motion) y `Responsive checks:`; no cambiar conteos de controles hasta la feature de navegación.

## Expected File Changes (for implementer; planner edits only this spec)

- `index.html` — rótulo, punto y posible agrupación semántica del Perfil; conservar resto intacto.
- `styles.css` — tokens/reglas de lienzo, tarjeta y Perfil; CSS de Enlaces/descarga/pie solo si requiere ajuste estrictamente necesario sin cambio funcional.
- `DESIGN.md` — convertir dirección de Perfil en reglas implementadas; diferenciar mediciones históricas de nuevo estado y actualizar valores reales, no simular que las capturas dan píxeles exactos.
- `CONSTRAINTS.md` — actualizar solo si cambia una regla durable de geometría/contraste; mantener todos los MUST AA y responsive. `init.sh` — ajustar/asertar contratos afectados, checks del rótulo y punto; gate local no bloqueante, nunca servidor por defecto.
- `feature_list.json`, `PROGRESS.md` — evidencia real y estado de implementación/validación; `docs/validations/redesign-card-profile.md` solo en validación independiente. No tocar datos binarios de avatar/vCard/OG.

## Visual Design Impact

- UI: sí; fuente versionada `DESIGN.md` § rediseño. Vistas: perfil normal móvil/escritorio, 320px, viewport corto, avatar en fallback y foto restaurada. No se requiere nuevo artefacto visual versionado; las dos capturas del propietario son referencias externas y deben solicitarse para la revisión humana. Si no están accesibles al implementador, documentar la limitación y pedir revisión, no proclamar fidelidad ni aprobación.
- El verde puede ser decorativo incluso si es llamativo; la ficha no debe atribuir a Fahed disponibilidad, conexión o estado de NFC.

## Durable Documentation Impact

- `ARCHITECTURE.md`: no crear; no cambia dominios, runtime ni límites arquitectónicos.
- `CONSTRAINTS.md`: revisar y actualizar **si** cambia algún MUST vigente (p. ej. token de contraste o fórmula de tarjeta); si no cambia, registrar explícitamente que sigue vigente.
- `AGENTS.md`: no actualizar; flujo y definición de terminado sin cambios.
- `DESIGN.md`: actualizar en implementación; fuente de verdad de nuevos valores. `docs/build-brief.md`/`docs/domain-model.md`: actualizar solo si la implementación modifica el alcance de producto previsto (no esperado). `docs/technical-discovery.md`: actualizar mediciones/comandos si cambian; `docs/risks-and-open-questions.md`: registrar referencias/contraste o aprobación visual pendiente si siguen abiertos. `PROGRESS.md`/`feature_list.json`: registrar la evidencia al implementar; **no** actualizar por este planner según instrucción de alcance.

## Implementation Plan / Tasks

1. [ ] Comparar las referencias si el propietario las facilita; fijar decisiones de layout/color en `DESIGN.md` y un plan de contraste sin debilitar AA. Las capturas no estaban accesibles en el repositorio durante esta implementación, así que la comparación visual del propietario sigue pendiente.
2. [x] Modificar solo el encabezado necesario en `index.html`; verificar textos, idiomas, fallback, árbol accesible y resto del documento intacto.
3. [x] Aplicar reglas de tarjeta/Perfil en `styles.css`, controlar overflow y fallback; mantener foco, movimiento reducido y botones funcionales.
4. [x] Adaptar `init.sh` a las reglas realmente cambiadas y añadir checks del ornamento; sincronizar documentación durable aplicable y pruebas negativas en copia temporal.
5. [x] Ejecutar verificación local y navegador; registrar evidencia medida y solicitar revisión visual humana separada. La revisión visual no equivale a la validación independiente.

## Verification Plan

- `bash -n init.sh && ./init.sh` → exit 0; confirmar salidas de `Accessibility checks:`/`Responsive checks:`/metadatos/vCard y ausencia de servidor. En copias temporales fuera del repo, eliminar rótulo/punto ornamental o su semántica correcta, romper fallback/`alt`/token de contraste y comprobar exit 1 concreto sin listener; no cambiar baseline para evitar fallos.
- Servir manualmente solo con `python3 -m http.server 3601 --directory .` en esta worktree aislada; el hint y `RUN_SERVE_COMMAND` de `init.sh` también usan 3601. Detener y confirmar el puerto libre al terminar.
- DevTools: cargar fresco 390×844 (móvil/táctil) y 1280×800 (escritorio), capturar geometría y estilos computados, screenshot de ambos, árbol accesible, consola sin errores y red sin recursos fallidos; comprobar `/`, CSS, avatar y vCard. Probar foco por teclado, hover y `prefers-reduced-motion: reduce` en controles existentes; comparar destinos y metadatos con el estado previo.
- Matriz con recarga fresca: 320×844, 360×844, 375×844, 390×844, 480×844, 736×800, 768×800, 1280×800; medir `documentElement` y `body` scrollWidth/clientWidth, card visible, texto no recortado y controles ≥44×44. Simular fallo del avatar de modo aislado y restaurar; registrar el 404 **esperado** solo en ese escenario y comprobar normal de nuevo sin 404.
- Lighthouse móvil en `http://localhost:3601/`: Accessibility ≥95 y cero `critical`/`serious`; auditar contraste de todos los pares nuevos ≥4.5:1 donde aplique, además de ratios fijados en reposo/hover/foco. No existe comando E2E persistente; gate + navegador + Lighthouse sustituyen E2E, sin añadir dependencias para este slice. `git diff --check` y diff de destinos/VCF/OG.
- **Aprobación separada:** entregar capturas del resultado 390×844/1280×800 al propietario y pedir comparación con las referencias originales en móvil/escritorio. Registrar fecha, dispositivo/contexto y respuesta explícita (aprobado o cambios pedidos) en `PROGRESS.md`/`feature_list.json`; si no hay respuesta, dejar `owner visual review: pending` y **no** marcar `accepted` aunque la implementación y el validador técnico pasen. No afirmar pruebas en dispositivos reales si solo se emuló Chrome.

## Evidence To Capture

- Salida y exit de `./init.sh`, negativos, contraste y Lighthouse; dimensiones/scroll por viewport; capturas, console/network normal y simulación de fallo separadas; diff que prueba siete href, vCard y metadatos intactos.
- Registro técnico de implementador (`passing` si corresponde) distinto del veredicto independiente y de la aprobación visual del propietario. Ausencia de capturas de referencia/feedback del propietario es riesgo/pendiente, **no** evidencia positiva.

## Validator Checklist

- [ ] Solo este slice; los otros cinco rediseños siguen sin implementar; siete Enlaces, vCard, pie y metadatos intactos.
- [ ] Escenarios normales, fallback, semántica ornamental y AA/8 anchos reproducidos; consola/red limpias en carga normal, 404 simulado separado.
- [ ] `init.sh` no arranca servicio y sigue fallando ante regresiones; ninguna relajación silenciosa de `Accessibility checks:` o `Responsive checks:`.
- [ ] Lighthouse móvil ≥95 sin `critical`/`serious`; foco y reduced motion observados; documentación de tokens/contratos sincronizada.
- [ ] Evidencia técnica, validación independiente y revisión visual del propietario diferenciadas. Si falta la última, no declarar aceptación visual ni `accepted`.

## Open Risks / Blocking Conditions

- Las capturas originales no están versionadas: **bloquea comparación visual concluyente y aceptación final hasta que el propietario revise el resultado**; no bloquea redactar el spec ni implementar/probar el slice localmente.
- La base 51 tokens/contrastes y checks textuales de `init.sh` pueden chocar con ajustes visuales. Tratar cada cambio de contrato explícitamente; nunca «arreglar» un gate quitando aserciones AA. La publicación/live no forma parte de esta feature y seguirá mostrando el diseño antiguo hasta redeploy manual posterior.
