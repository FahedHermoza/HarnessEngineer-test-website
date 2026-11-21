# Harness dual: OpenCode + Claude Code

Este repositorio ejecuta el **mismo harness de agentes sobre dos herramientas**: **OpenCode** y
**Claude Code**. Este documento fija qué es fuente única, qué es adaptador por herramienta, y las
reglas para que ambos lados no se desincronicen.

## Mapa de propiedad

| Capa | Archivos | Quién la lee | Estrategia |
|---|---|---|---|
| **Contrato de proyecto** (tool-agnóstico) | `AGENTS.md`, `CONSTRAINTS.md`, `CONTEXT.md`, `DESIGN.md`, `feature_list.json`, `PROGRESS.md`, `init.sh`, `docs/` | Ambas (Claude lee `AGENTS.md` nativamente desde v2.1.277) | **Archivo único compartido.** Sin duplicación. |
| **Skills** | `.agents/skills/<name>/` | OpenCode (default fijo) + Claude vía symlink | **Fuente única = `.agents/skills/`.** Ver abajo. |
| **Subagentes** | `.opencode/agent/*.md` ↔ `.claude/agents/*.md` | OpenCode / Claude | Adaptador por herramienta (formato divergente). |
| **Comandos** | `.opencode/command/*.md` ↔ `.claude/commands/*.md` | OpenCode / Claude | Adaptador por herramienta. |
| **MCP** | `opencode.json` ↔ `.mcp.json` | OpenCode / Claude | Adaptador por herramienta. |
| **Local/personal** | `.claude/settings.local.json` | Claude | Fuera de git; no es parte del contrato. |

## Skills: fuente única vía symlinks

Canónico: **`.agents/skills/`** (lo mantiene el CLI upstream `devexpert-io/ai-expert-project` vía
`skills-lock.json`). Claude los ve porque `.claude/skills/<name>` es un **symlink por skill** a
`../../.agents/skills/<name>`. Editas un skill en un solo sitio y ambas herramientas lo ven.

Claude Code sigue symlinks de skills oficialmente (una entrada `<skill-name>` puede apuntar a otro
directorio). Las rutas internas de los skills (`../../../AGENTS.md`) resuelven igual porque tanto
`.claude/skills/<name>/` como `.agents/skills/<name>/` están a 3 niveles de la raíz.

### Regenerar los symlinks (tras cambios del CLI upstream)

Cuando el CLI upstream añade o quita skills en `.agents/skills/`, re-crear los symlinks:

```bash
cd "$(git rev-parse --show-toplevel)"
find .agents/skills -name .DS_Store -delete
rm -rf .claude/skills
mkdir -p .claude/skills
for d in .agents/skills/*/; do
  name=$(basename "$d")
  ln -s "../../.agents/skills/$name" ".claude/skills/$name"
done
git add -A .claude/skills
```

**Fallback:** si alguna versión de Claude no resolviera un symlink por skill, reemplazar `ln -s`
por `cp -R .agents/skills/$name .claude/skills/$name` en el bucle (copia real en vez de symlink) y
re-ejecutar tras cada cambio de skill.

## Adaptadores por herramienta: mapeo OpenCode → Claude

Los adaptadores se mantienen a mano (son archivos mínimos). Si cambias uno en un lado, **refleja el
cambio en el otro**.

| Pieza | OpenCode | Claude |
|---|---|---|
| **Subagentes** | `.opencode/agent/*.md`: `mode: subagent`, `model: openai/...`, `variant: max`, bloque `permission:` | `.claude/agents/*.md`: `name:`, `tools:` (allowlist), `model:` alias |
| **Modelos** | `openai/gpt-6-sol` (planner), `openai/gpt-6-luna` (implementer), `openai/gpt-6.1-sol` (validator) | `opus` (planner), `sonnet` (implementer), `opus` (validator) |
| **Permisos** | `permission.edit/bash/skill/task` con allow/deny y globs | se colapsa en `tools:` — omitir `Edit`/`Write` = edición denegada; omitir `Agent` = task denegada |
| **Comando** | `.opencode/command/rebase-pr.md` con campo extra `agent: build` | `.claude/commands/rebase-pr.md` sin ese campo; `$ARGUMENTS` es compatible en ambos |
| **MCP** | `opencode.json`: `type: local`, `command: [array]`, `enabled` | `.mcp.json`: `command` (string) + `args` (array) |

## Reglas de sincronización

- **No crear `CLAUDE.md` ni `CLAUDE.local.md`** en el repo: cualquiera de los dos hace que Claude
  deje de leer `AGENTS.md` (salvo cambiar el setting **Project instructions** a
  `claude-md-and-agents-md`).
- Los nombres de subagentes deben permanecer **`planner` / `implementer` / `validator`**: el skill
  `feature-flow` los orquesta por nombre en ambas herramientas.
- Un MCP nuevo, un comando nuevo o un cambio de permisos/modelo en un subagente → aplicar en los dos
  lados (OpenCode y Claude) según la tabla de arriba.
- Añadir/quitar skills se hace vía el CLI upstream en `.agents/skills/`; luego regenerar symlinks.

## Verificación rápida

```bash
# Los symlinks de skills resuelven y git los guarda como symlinks (modo 120000)
ls -lL .claude/skills/*/SKILL.md
git ls-files -s .claude/skills | grep 120000

# La ruta interna de los skills sigue apuntando a la raíz
ls .claude/skills/feature-flow/../../../AGENTS.md   # -> AGENTS.md
```

Tras reiniciar Claude Code: confirmar que lista los 8 skills y los 3 subagentes
(`planner`/`implementer`/`validator`), y que el MCP `chrome-devtools` carga desde `.mcp.json`.
OpenCode no se ve afectado porque `.agents/skills/` (el directorio real) no cambió.
