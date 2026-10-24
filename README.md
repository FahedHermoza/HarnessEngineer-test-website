# Tarjeta digital de Fahed Hermoza

Página web estática de una sola vista, móvil-first y sin build, que reúne el Perfil, los siete
Enlaces de contacto y un botón para guardar la Contacto (vCard). Es el destino de la Tarjeta NFC
y del Código QR.

- **Producción:** <https://fahed-hermoza-card.fahedhermoza.workers.dev/>
- **Stack:** HTML5 + CSS moderno; sin framework, bundler, backend ni dependencias de runtime.
- **Estado:** 20 features `accepted`; `deploy-cloudflare-pages` en `passing`, pendiente de la
  verificación live posterior al redeploy.

## Qué incluye

- Perfil con avatar circular, fallback de iniciales `FH`, Nombre, Handle y Tagline.
- Siete Enlaces en orden: Instagram, Facebook, WhatsApp, LinkedIn, Portafolio, Correo y Celular.
- Botón **Guardar contacto** que descarga `assets/fahedhermoza.vcf`.
- Pie con correo y Handle.
- Metadatos Open Graph/Twitter con URL de producción e imagen `assets/og-image.jpg` 1200×630.
- Base de accesibilidad AA y layout responsive fluido de 320 a 1280 px.

## El Harness del proyecto

Este repositorio no se mantiene solo con código: incluye un **harness para agentes** que hace
explícitos el contexto, el estado, las reglas y la verificación. La idea es que cualquier sesión
( humana o agente) pueda retomarlo sin depender de memoria de chat y sin declarar terminado algo
que solo “parece” funcionar.

### Artefactos que gobiernan el trabajo

| Artefacto | Rol |
|---|---|
| `AGENTS.md` | Contrato del repositorio: qué leer, cómo arrancar, reglas de trabajo y Definition of Done. |
| `init.sh` | Gate ejecutable del harness. Valida bootstrap, tokens, layout, contenido, metadatos, vCard, accesibilidad y responsive sin arrancar servidor por defecto. |
| `feature_list.json` | Fuente de verdad del estado de cada feature, dependencias, criterios de verificación y evidencia. |
| `PROGRESS.md` | Estado verificado actual y bitácora de sesiones. |
| `docs/specs/<feature>.md` | Plan de implementación de una feature concreta. |
| `docs/validations/<feature>.md` | Registro de la validación independiente. |

Estados de una feature:

1. `not_started` — pendiente.
2. `passing` — implementada y auto-verificada; **no** es aceptada.
3. `accepted` — validada de forma independiente y con evidencia registrada.

### Flujo de una feature

```
planner → implementer → validator → accepted → commit
             ↑              │
             └── revise ────┘
```

- **planner** (`$feature-spec`): escribe `docs/specs/<feature>.md`; no toca código de producto.
- **implementer** (`$feature-implementer`): implementa una sola feature, la auto-verifica y la deja
  en `passing`.
- **validator** (`$feature-validator`): revisa de forma independiente contra el spec, el diff, el
  gate y el navegador; devuelve `accept`, `revise` o `block`.
- **orquestador** (`$feature-flow`): encadena los roles, persiste la aceptación y hace el commit.
- **`$github-flow`**: lleva una feature a issue, rama, worktree y PR.
- **`$rebase-pr`**: resuelve errores de “Rebase and merge” en una PR.

Los roles están configurados como subagentes en `.opencode/agent/` (`planner`, `implementer`,
`validator`) y las instrucciones reutilizables viven en `.agents/skills/`.

### Reglas del harness

- Una feature a la vez; no se marca completa solo porque se añadió código.
- No se debilitan ni se reordenan los checks de `init.sh`.
- Todo cambio visual se valida en navegador real: móvil 390×844 y escritorio 1280×800, sin errores
  de consola ni peticiones fallidas.
- La base AA debe seguir verde: `Accessibility checks:` + Lighthouse móvil ≥95 sin fallos
  `critical`/`serious`.
- La evidencia se guarda en `feature_list.json`/`PROGRESS.md`, no solo en el chat.
- No se añaden frameworks, bundlers ni dependencias sin justificarlo.
- Las decisiones subjetivas (aprobación de la imagen OG) y las acciones externas (redeploy,
  unfurl social) son comprobaciones humanas explícitas.

El harness incluye además el MCP `chrome-devtools` en `opencode.json` para inspeccionar consola,
red, layout y ejecutar Lighthouse contra el sitio servido localmente.

## Inicio rápido

Requisitos: `bash`, `python3`, `git` y un navegador (Chrome para las comprobaciones manuales).

```bash
# 1. Verificación base del harness (no arranca servidor)
./init.sh

# 2. Servir la Tarjeta en local
python3 -m http.server 3502 --directory .

# 3. Abrir
open http://localhost:3502/
```

Alternativa en un solo paso:

```bash
RUN_SERVE_COMMAND=1 ./init.sh
```

`./init.sh` debe salir con código `0`. Hoy imprime **109 `[ok]`** y ningún `[warn]`. El servidor
solo se inicia con `RUN_SERVE_COMMAND=1`.

## Verificación

### Gate automático

`./init.sh` cubre, entre otras secciones:

- `bootstrap`: documento válido, `lang="es"`, título y viewport.
- `design tokens`: 51 custom properties de `DESIGN.md`.
- `Component checks:` y `page shell`.
- Perfil, avatar, fallback, identidad, pie y los siete Enlaces con su orden y tonos.
- `Sharing metadata contract (14/14)` y `Sharing metadata production checks:` (`canonical`,
  `og:url`, imágenes absolutas y `assets/og-image.jpg` JPEG 1200×630).
- `Save contact checks:` con validación byte a byte de la vCard.
- `Accessibility checks:`: foco visible, `aria-hidden`, `alt`, idioma, reduced motion y contraste
  calculado.
- `Responsive checks:`: sin máscaras de overflow, fórmula fluida de tarjeta y objetivos táctiles.

### Validación manual

```bash
python3 -m http.server 3502 --directory .
```

- Móvil **390×844** y escritorio **1280×800**: consola limpia, red sin fallos, sin scroll horizontal.
- Matriz responsive: 320, 360, 375, 390, 480, 736, 768 y 1280 px.
- Lighthouse móvil de accesibilidad ≥95, sin `critical`/`serious`.
- Pruebas negativas en copias temporales fuera del repo: cada regresión del gate debe salir con
  código `1`, mensaje en stderr y sin listener.

### Verificación live (tras el redeploy)

```bash
BASE="https://fahed-hermoza-card.fahedhermoza.workers.dev"

for p in / /styles.css /assets/avatar.jpg /assets/og-image.jpg /assets/fahedhermoza.vcf; do
  printf '%s ' "$p"
  curl -sS -o /dev/null -w '%{http_code} %{content_type} %{size_download}\n' "$BASE$p"
done
```

Se espera `200` en los cinco paths, `image/jpeg` para la imagen OG y `text/x-vcard` para la vCard.
Los hashes locales y remotos deben coincidir. Usa `?cb=$(date +%s)` solo para saltar caché de
verificación.

## Publicación

- Plataforma: **Cloudflare Workers con static assets** (no Cloudflare Pages).
- Origen único: `https://fahed-hermoza-card.fahedhermoza.workers.dev/`.
- Sin comando de build: se publica la raíz del repositorio (`index.html`, `styles.css`,
  `assets/`).
- El despliegue se dispara al llegar a `main` y lo opera el propietario; no hay `wrangler.toml`,
  CI ni credenciales en el repo.
- Si cambia el origen, actualiza juntos `PRODUCTION_ORIGIN`/`PRODUCTION_URL`/
  `PRODUCTION_IMAGE_URL` en `init.sh` y las cuatro URLs del `<head>`.

## Estructura

```
.
├── index.html                  # Página completa (Perfil, Enlaces, vCard, pie)
├── styles.css                  # Tokens y componentes de "Serene Bio Card"
├── init.sh                     # Gate ejecutable del harness
├── AGENTS.md                   # Contrato para agentes
├── PROGRESS.md                 # Estado verificado y bitácora
├── feature_list.json           # Fuente de verdad de las features
├── DESIGN.md                   # Sistema visual (tokens, layout, componentes)
├── CONSTRAINTS.md              # Reglas durables AA, responsive y publicación
├── CONTEXT.md                  # Vocabulario del dominio
├── assets/
│   ├── avatar.jpg
│   ├── og-image.jpg            # Open Graph 1200×630
│   └── fahedhermoza.vcf        # vCard 3.0 estática (CRLF)
├── docs/
│   ├── build-brief.md
│   ├── domain-model.md
│   ├── technical-discovery.md
│   ├── risks-and-open-questions.md
│   ├── specs/
│   └── validations/
├── .agents/skills/             # Skills del harness
└── .opencode/agent/            # planner, implementer, validator
```

## Documentación

| Documento | Contenido |
|---|---|
| `CONTEXT.md` | Glosario del dominio. |
| `CONSTRAINTS.md` | Reglas MUST/MUST NOT de accesibilidad, responsive y publicación. |
| `DESIGN.md` | Fuente de verdad visual: tokens, tipografía, layout y componentes. |
| `docs/build-brief.md` | Problema, objetivos, alcance del MVP y criterios de éxito. |
| `docs/domain-model.md` | Entidades, relaciones, escenarios y edge cases. |
| `docs/technical-discovery.md` | Stack, datos, integraciones, despliegue y verificación. |
| `docs/risks-and-open-questions.md` | Riesgos, supuestos y pendientes. |
| `AGENTS.md` | Cómo debe trabajar un agente en este repositorio. |

## Pendientes conocidos

- Verificación live de `deploy-cloudflare-pages` tras el redeploy y validación independiente.
- Unfurl real en WhatsApp/Facebook (depende de caché y políticas del cliente).
- Importación real de la vCard en iOS y Android.
- Activar “Always Use HTTPS” en Cloudflare (`http://` responde 200 hoy).
- `meta description` y analítica están fuera del alcance actual.
- No hay E2E persistente: la cobertura es `init.sh` + Chrome DevTools + Lighthouse + `curl` live.
