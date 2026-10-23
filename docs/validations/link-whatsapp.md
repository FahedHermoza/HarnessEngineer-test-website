# Validación: Enlace a WhatsApp

- Feature: `link-whatsapp`
- Spec: `docs/specs/link-whatsapp.md`
- Fecha: 2026-10-23
- Rol: validator independiente (`feature-validator`)
- Estado revisado: `passing` (auto-verificación del implementador)
- Veredicto: **accept**
- Estado recomendado para el orquestador: `accepted` (el validator no modificó `feature_list.json`)

## Alcance revisado

Se revisaron el spec, el diff actual, `feature_list.json`, `PROGRESS.md`, `docs/risks-and-open-questions.md`, `index.html`, `styles.css` e `init.sh`. La implementación añade un Enlace real de WhatsApp dentro de un contenedor `.links` mínimo, conserva la demo temporal y extiende el harness no bloqueante. No se revisaron ni aceptaron otras features.

## Verificación ejecutada de forma independiente

### Sintaxis y gate estándar

```text
$ bash -n init.sh
exit 0

$ ./init.sh
Harness status: bootstrapped (static site detected)
Bootstrap checks: 3/3 [ok]
Design token checks: 51/51 [ok]
Component checks: 6/6 + prefers-reduced-motion [ok]
Page shell checks: 3/3 [ok]
Profile checks: 5/5 [ok]
Page footer checks: 5/5 [ok]
Profile identity checks: [ok]
Sharing metadata checks: 14/14 [ok] + 3 [warn] esperados
Link checks:
  [ok] whatsapp link markup
  [ok] whatsapp link label
  [ok] whatsapp icon contract (6/6)
  [ok] .links base rule exists
  [ok] links section contract (4/4)
Serving command: python3 -m http.server 3303 --directory .
exit 0
```

El puerto 3303 estaba libre antes del gate y siguió libre después; `./init.sh` no arrancó ningún servidor.

### Casos negativos (copias temporales fuera del repo)

Se crearon cinco copias temporales independientes, se alteró un único aspecto en cada una y se ejecutó `./init.sh`. Todas salieron con código 1, escribieron el fallo en stderr y no dejaron listener en 3303. Las copias se eliminaron.

| Caso | Exit | Evidencia stderr |
| --- | --- | --- |
| `href` cambiado a `api.whatsapp.com` | 1 | `Harness status: FAILED - index.html is missing the WhatsApp link markup (...)` |
| Sin `aria-label="WhatsApp"` | 1 | `Harness status: FAILED - index.html is missing the WhatsApp link markup (...)` |
| Etiqueta visible `Whatsapp` | 1 | `Harness status: FAILED - index.html is missing the visible WhatsApp link label: >WhatsApp<` |
| SVG de WhatsApp sin `aria-hidden="true"` | 1 | `FAILED - WhatsApp link icon is missing attribute: aria-hidden="true"` y `whatsapp icon contract is missing 1 of 6 required attributes` |
| `.links` sin `gap: var(--space-sm);` | 1 | `FAILED - .links base rule missing declaration: gap: var(--space-sm);` y `links section contract is missing 1 of 4 required declarations` |

### Scope guard estático

- `:root` conserva exactamente 51 custom properties y el diff no añade tokens.
- 0 elementos `<script>`; no hay `package.json`, `node_modules`, framework, bundler ni dependencia de producto nueva.
- `.link-button` no cambia: la regla base y los modificadores `gradient-1`…`gradient-5` son idénticos a `HEAD`.
- La demo `[data-demo="link-button"]` y su CSS son byte-idénticos a `HEAD`; conserva 5 anclas, etiquetas `Enlace uno`…`Enlace cinco`, tonos 1…5, `href="#link-button-demo"` y chevrons.
- No hay `target=`, `nth-child`, `nth-of-type` ni `order` en `.links`.
- `assets/avatar.jpg` conserva SHA-256 `b73575ae31cee7ead9de09377d90b60d3cbf2079402602c217a47f02afe4aa7c`, idéntico a `HEAD`.
- `git diff --check` no reporta errores.
- `.links` es un contenedor presentacional mínimo: flex column, `gap: var(--space-sm)`, padding lateral de gutter y sin lógica de orden o degradado.

### Navegador (servidor propio en 3303, detenido al terminar)

Se usó un único servidor `python3 -m http.server 3303 --directory .` iniciado para esta validación y se detuvo después; 3303 quedó libre. Las dos cargas se hicieron con navegación fresca e `ignoreCache`.

**390×844**

- Consola: 0 mensajes.
- Red: 5/5 peticiones exitosas (`/` 200, Google Fonts CSS 200, `styles.css` 200, `avatar.jpg` 200, WOFF2 200); sin `/favicon.ico` ni 4xx/5xx.
- `documentElement.scrollWidth = clientWidth = 390`; `body.scrollWidth = clientWidth = 390`; sin scroll horizontal.
- Tarjeta 358×817 en x=16. `.links` 356×48 en x=17, `aria-label="Enlaces"`, flex column, gap 12px, padding `0px 16px`.
- Enlace real `<a>` 324×48 en x=33; `href="https://wa.me/51955116562"` exacto (propiedad y atributo), `aria-label="WhatsApp"`, texto `WhatsApp`, sin `target` ni `rel`; clases `link-button link-button--gradient-1`.
- Estilos computados: fondo `rgb(104, 118, 240)`, blanco, radio 6px, padding `0px 20px`, 11px/800, line-height 16px, tracking 1.98px, mayúsculas, `space-between`.
- Icono `<svg>` inline 18×18, `viewBox="0 0 24 24"`, `fill="currentColor"`, `aria-hidden="true"`, `focusable="false"`, un `path`; fill computado blanco. No hay petición de imagen para el icono.
- Orden estructural: `header.profile-identity` → `section#links` → `section#link-button-demo`.
- Demo intacta: 5 anclas con sus 5 etiquetas y `href="#link-button-demo"`, chevrons decorativos.
- Total `.link-button`: 6 (1 real + 5 demo).
- Árbol de accesibilidad: región `Enlaces`; enlace `"WhatsApp"` con URL `https://wa.me/51955116562`.
- `Tab`: el Enlace recibe `:focus-visible=true`, outline `rgb(88, 92, 229) solid 2px`, offset 2px, transform `matrix(1, 0, 0, 1, 0, -1.5)` y sombra hover.

**1280×800**

- Consola: 0 mensajes.
- Red: 5/5 peticiones exitosas (`/` 200, Google Fonts CSS 200, `styles.css` 304 de revalidación, `avatar.jpg` 200, WOFF2 200); sin `/favicon.ico` ni 4xx/5xx. El 304 es una revalidación correcta, no una petición fallida.
- `documentElement.scrollWidth = clientWidth = 1265`; `body.scrollWidth = clientWidth = 1265`; sin scroll horizontal. El cliente mide 1265 porque hay una barra vertical de 15px (la página supera 800px de alto).
- Tarjeta 400×817 en x=432.5. `.links` 398×48 en x=433.5.
- Enlace real 366×48 en x=449.5; mismas clases, `href`, `aria-label`, ausencia de `target`, estilos, icono y contrato que en móvil.
- Demo intacta: 5 anclas, etiquetas, tonos, `href` y chevrons.
- Total `.link-button`: 6 (1 real + 5 demo).
- Árbol de accesibilidad: región `Enlaces`; enlace `"WhatsApp"` con URL exacta.
- `Tab`: `:focus-visible=true`, outline `rgb(88, 92, 229) solid 2px`, offset 2px, transform y sombra de foco.

## Hallazgos

No hay hallazgos Critical, High ni Medium.

### Nota Low: la geometría de escritorio del spec asume ausencia de scrollbar

- Severidad: Low
- Evidencia: el spec espera el Enlace en x=457 y la tarjeta en x=440; la medición real es x=449.5 y x=432.5 porque el documento mide 817px de alto y el navegador reserva 15px para la barra vertical. El ancho del Enlace (366px), la tarjeta (400px), el centrado y la ausencia de scroll horizontal sí coinciden.
- Por qué importa: es una diferencia de evidencia/geometría esperada, no un defecto del Enlace ni overflow horizontal.
- Cambio requerido: ninguno para aceptar. Si se desea exactitud documental, anotar en el spec que 1280×800 puede tener una barra vertical y desplazar el eje X.
- Verificación: `scrollWidth === clientWidth === 1265`, ancho real 366px y sin overflow horizontal.

### Nota Low: checks del harness son textuales

- Severidad: Low
- Evidencia: `init.sh` comprueba markup con `grep -F`, la etiqueta visible con `>WhatsApp<` global y atributos del SVG por subcadena dentro del bloque del ancla.
- Por qué importa: son suficientes para este repo de un solo archivo y fallan correctamente en los cinco casos negativos, pero podrían dar un falso positivo ante markup extraño que repita esos fragmentos.
- Cambio requerido: ninguno para aceptar; una futura mejora sería validar el label dentro del ancla o parsear el HTML.

### Nota Low: handoff real pendiente en dispositivo

- Severidad: Low
- Evidencia: `docs/risks-and-open-questions.md` y el spec registran que abrir WhatsApp con el chat correcto no se puede automatizar en este repositorio.
- Por qué importa: el contrato verificable (`href` exacto, `<a>` real, sin `target`) está correcto, pero la experiencia final depende de la app/dispositivo.
- Cambio requerido: ninguno para aceptar; comprobar manualmente en un teléfono real antes del cierre de producto.

## Evaluación de seguridad

Sin hallazgos de seguridad relevantes para esta feature. No hay secretos, entradas de usuario, autenticación, formularios, llamadas de red nuevas ni `target="_blank"`/`rel` que amplíen la superficie. El único destino externo es el `href` estático confirmado `https://wa.me/51955116562`, y el icono es SVG inline sin carga remota.

## Documentación y consistencia

- `docs/specs/link-whatsapp.md` existe y describe el comportamiento implementado.
- `feature_list.json` está en `passing` con evidencia del implementador, coherente con la validación pendiente.
- `PROGRESS.md` registra el estado verificado y la Session 019.
- `docs/risks-and-open-questions.md` resuelve el formato `wa.me` y documenta el handoff manual.
- La validación independiente se persiste en este archivo; el validator no cambió `feature_list.json`, no hizo commit ni push.

## Seguimiento recomendado

1. El orquestador puede mover `link-whatsapp` de `passing` a `accepted` con la evidencia de este registro.
2. Mantener la comprobación manual del handoff en un dispositivo real.
3. `links-order-gradient` reasignará el tono final; `gradient-1` era provisional y está documentado.
