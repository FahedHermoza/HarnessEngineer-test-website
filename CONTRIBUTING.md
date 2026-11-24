# Estrategia de ramas (branching strategy)

## Resumen rápido

- **Ramas de larga vida:** `demo/seed` (integración) y `main` (producción, dispara el deploy).
- **Feature → `demo/seed`:** `git worktree` aislado desde el SHA actual de `demo/seed`; mergear con **"Rebase and merge"**; borrar rama y worktree después.
- **`demo/seed` → `main`:** mergear **siempre** con **"Create a merge commit"** — nunca squash ni rebase (ver sección 2, es la regla que más importa).
- **Tras cada promoción a `main`:** traer ese merge commit de vuelta a `demo/seed` (`git merge origin/main`) para mantener el ancestro común sano.
- **Toda PR debe cerrar un issue:** el cuerpo debe incluir la línea literal `Closes #<n>` (sin texto extra pegado) para que GitHub la cierre automáticamente al mergear.
- **Antes de pushear:** `./init.sh` debe salir `0`.

Este repositorio usa dos ramas de larga vida:

- **`demo/seed`** — rama de integración. Todas las features aterrizan aquí primero. `github-flow` crea cada worktree de feature desde el SHA actual de `demo/seed`.
- **`main`** — producción. El deploy a Cloudflare Workers static assets se dispara al llegar a `main`. No se edita directo; solo recibe promociones desde `demo/seed`.

```
feature/<id>  ──(rebase and merge)──▶  demo/seed  ──(create a merge commit)──▶  main
```

## 1. Feature → `demo/seed`: **Rebase and merge**

Cada feature vive en su propia rama `feature/<feature-id>` y worktree aislado (ver skill `github-flow`), creada desde el SHA actual de `demo/seed`.

Al mergear la PR de la feature a `demo/seed`, usar **"Rebase and merge"** (o "Squash and merge" si se prefiere un solo commit por feature):

```bash
gh pr merge <n> --rebase
```

Esto mantiene un historial lineal y legible por feature en `demo/seed`. Es seguro reescribir hashes en este punto porque `feature/<id>` es una rama efímera que se borra después del merge (no hay nadie más dependiendo de ella).

**Tras el merge:** borrar la rama y el worktree de la feature (`github-flow` ya lo automatiza):

```bash
git worktree remove ../devexpert-project-worktrees/<feature-id>
git branch -d feature/<feature-id>
git push origin --delete feature/<feature-id>
```

## 2. `demo/seed` → `main`: **Create a merge commit** (obligatorio, nunca squash/rebase)

Cuando `demo/seed` tiene features `accepted` listas para producción, se abre una PR `demo/seed → main` y se mergea **siempre** con **"Create a merge commit"**:

```bash
gh pr merge <n> --merge
```

### Por qué esta regla es obligatoria

Si esa PR se mergea con squash o rebase, GitHub reescribe los commits de `demo/seed` con **hashes nuevos** dentro de `main`. El contenido queda idéntico, pero Git ya no reconoce un ancestro común real entre las dos ramas. A partir de ahí, cualquier diff o rebase futuro entre `demo/seed` y `main` sale en **conflicto falso** (se vio un diff de 73 archivos sin cambios reales la primera vez que pasó esto). El único arreglo disponible después del hecho es crear una rama temporal desde `main`, hacer `cherry-pick` de los commits realmente nuevos, y mergear eso — mucho más trabajo que simplemente haber usado "Merge commit" desde el principio.

**"Create a merge commit" preserva los mismos objetos de commit en ambas ramas**, así que el ancestro común se mantiene correcto y las futuras promociones son limpias.

## 3. Tras mergear `demo/seed` → `main`: sincronizar de vuelta

Inmediatamente después de mergear la promoción a `main`, traer ese merge commit de vuelta a `demo/seed` para que el ancestro común quede sano para la próxima vez:

```bash
git fetch origin main demo/seed
git checkout demo/seed
git merge origin/main   # fast-forward o merge trivial; el contenido ya coincide
git push origin demo/seed
```

Este paso es el que de verdad mantiene sincronizadas ambas ramas a nivel de **historial**, no solo de contenido.

## 4. Verificación de sincronía (correr antes de abrir cualquier PR de promoción)

```bash
git fetch origin main demo/seed
git log origin/main..origin/demo/seed --oneline   # commits realmente nuevos en demo/seed
git diff --stat origin/main origin/demo/seed       # debe coincidir con esos commits; vacío = idéntico
gh api repos/<owner>/<repo>/compare/main...demo/seed -q '"ahead=\(.ahead_by) behind=\(.behind_by) status=\(.status)"'
```

Si el diff de archivos está vacío pero `ahead_by` no es 0, es el mismo síntoma cosmético de un squash/rebase previo: el contenido coincide, pero el historial tiene commits "fantasma" de identidad duplicada. No es necesariamente grave, pero si se quiere un historial realmente limpio (badge en 0), ver la sección 5.

## 5. Si ya ocurrió el conflicto (squash/rebase accidental en `demo/seed → main`)

1. **No** hacer `git rebase` ni force-push directo sobre `demo/seed` como primer intento — es una rama compartida e integradora, no una rama de feature efímera.
2. Usar la skill `rebase-pr` o el siguiente camino manual, sin tocar `demo/seed`:
   ```bash
   git fetch origin main
   git checkout -b sync/demo-seed-to-main origin/main
   git cherry-pick <commits-realmente-nuevos>
   ./init.sh   # debe salir 0
   git push -u origin sync/demo-seed-to-main
   gh pr create --base main --head sync/demo-seed-to-main --title "..." --body "..."
   ```
3. Mergear esa PR con **"Create a merge commit"**.
4. Sincronizar de vuelta (paso 3 de arriba): `git merge origin/main` sobre `demo/seed` y push.
5. **Opcional** — limpiar el historial "fantasma" de `demo/seed` si el contenido ya es idéntico a `main` (confirmar con `git diff --stat origin/main origin/demo/seed` vacío antes de hacer esto):
   ```bash
   git tag backup/demo-seed-pre-cleanup origin/demo/seed
   git push origin backup/demo-seed-pre-cleanup   # red de seguridad, borrable después
   git checkout demo/seed
   git reset --hard origin/main
   ./init.sh   # debe salir 0
   git push --force-with-lease origin demo/seed
   ```
   Requiere: ningún otro worktree/clon activo sobre `demo/seed`, ninguna PR abierta con `demo/seed` como base o head, y el diff de contenido vacío confirmado antes de forzar. Si algo sale mal, recuperar con `git push --force-with-lease origin backup/demo-seed-pre-cleanup:demo/seed`.

## 6. Toda PR debe cerrar un issue con `Closes #<n>`

`github-flow` crea un issue por feature antes de abrir la PR. El cuerpo de la PR debe incluir la línea **literal** que GitHub reconoce como [closing keyword](https://docs.github.com/articles/closing-issues-using-keywords):

```
Closes #57
```

**No** envolverla en paréntesis ni pegarle texto en la misma línea — eso rompe el parseo del keyword y GitHub no cierra el issue al mergear:

```
❌ Closes #57 (al aceptar)        ← no se reconoce, el issue queda abierto
✅ Closes #57

   (el resto del contexto va en otra línea o párrafo aparte)
```

Esto no es teórico: así quedó el issue **#57** de `redesign-social-preview` — el cuerpo de la PR #58 decía `Closes #57 (al aceptar)`, GitHub no lo auto-cerró al mergear, y hubo que cerrarlo a mano con `gh issue close 57`. Revisar siempre tras mergear que el issue referenciado haya quedado cerrado; si no, cerrarlo manualmente y corregir la plantilla para la próxima PR.

## Resumen de la tabla de decisión

| Salto | Estrategia de merge | Reescribe hashes | Riesgo si se usa la otra |
|---|---|---|---|
| `feature/<id>` → `demo/seed` | Rebase and merge (o squash) | Sí, en una rama efímera (seguro) | Ninguno — la rama se borra después |
| `demo/seed` → `main` | **Merge commit, siempre** | No | Rompe el ancestro común; conflictos falsos en futuras promociones |
