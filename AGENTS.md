# Project Agent Instructions

Este repositorio contiene la **Tarjeta digital** de Fahed Hermoza: una página estática de una sola vista, móvil-first, sin backend ni build, que agrupa su Perfil, sus Enlaces de contacto y un botón para guardar la Contacto (vCard).

## Read First

- `CONTEXT.md` — vocabulario del dominio (Tarjeta digital, Enlace, Perfil, Handle, Tagline, Contacto).
- `CONSTRAINTS.md` — reglas durables MUST/MUST NOT, incluida la base de accesibilidad AA.
- `docs/build-brief.md` — problema, objetivos, alcance del MVP y criterios de éxito.
- `docs/domain-model.md` — entidades, relaciones, escenarios y edge cases.
- `docs/risks-and-open-questions.md` — riesgos, supuestos y preguntas abiertas.
- `DESIGN.md` — sistema visual "Serene Bio Card": tokens de color, tipografía, layout y componentes (fuente de verdad de diseño).
- `docs/technical-discovery.md` — stack, datos, integraciones, despliegue y verificación.

## Startup Workflow

Antes de escribir código:

1. Confirmar el directorio de trabajo con `pwd`.
2. Leer `PROGRESS.md` para conocer el estado verificado y el siguiente paso.
3. Leer `feature_list.json` y elegir la primera feature lista y sin terminar en el orden de la lista.
4. Ejecutar `./init.sh`.
5. Si la verificación base falla, arreglar la base antes de añadir trabajo de feature.

## Working Rules

- Trabajar en una sola feature a la vez.
- No marcar una feature como completa solo porque se añadió código.
- Mantener los cambios dentro del alcance de la feature elegida, salvo un bloqueo que exija un arreglo puntual.
- No cambiar silenciosamente las reglas de verificación durante la implementación.
- Actualizar los artefactos durables del repo en lugar de depender de resúmenes de chat.
- No introducir frameworks, bundlers ni dependencias nuevas sin justificarlo (ver `docs/technical-discovery.md`).
- Mantener la base de accesibilidad AA de `CONSTRAINTS.md` y el gate `Accessibility checks:` de `./init.sh`; no debilitar sus checks, tokens de contraste, foco, `aria-hidden`, `alt`, idioma ni reduced motion.
- `DESIGN.md` es la **fuente de verdad del diseño** y es **de solo lectura para quien implementa**: el código se ajusta a `DESIGN.md`, nunca al revés. No edites `DESIGN.md` para que calce con lo que codeaste. Si la implementación necesita diferir del diseño (nuevo valor, cambio de layout, tono, geometría), **detente y plantea una decisión de diseño** al propietario/planner *antes* de codear; el cambio se refleja primero en `DESIGN.md` (con aprobación) y luego se implementa. El gate `Design conformance checks:` de `./init.sh` falla si los colores declarados en `DESIGN.md` no coinciden con los tokens de `styles.css`.
- Toda feature con UI se valida también en navegador, en móvil (390×844) y escritorio (1280×800), sin errores de consola ni peticiones fallidas, antes de aceptarla.

## Required Artifacts

- `feature_list.json`: fuente de verdad del estado de las features.
- `PROGRESS.md`: estado verificado actual y bitácora ligera de sesión.
- `init.sh`: camino estándar de arranque y verificación.

## Definition Of Done

Una feature está terminada solo cuando todo lo siguiente es cierto:

- el comportamiento objetivo está implementado,
- la base AA sigue vigente: `./init.sh` pasa sus `Accessibility checks:` y la auditoría Lighthouse móvil de accesibilidad da ≥95 sin fallos `critical`/`serious`,
- la validación en navegador (móvil 390×844 y escritorio 1280×800) se ejecutó sin errores de consola ni peticiones fallidas,
- la verificación requerida realmente se ejecutó,
- la evidencia quedó registrada en `feature_list.json` o `PROGRESS.md`,
- el repositorio sigue siendo reiniciable desde `./init.sh`,
- los docs relevantes se actualizaron si cambió el comportamiento del producto, reglas de dominio, API o verificación.

## End Of Session

Antes de terminar una sesión:

1. Actualizar `PROGRESS.md`.
2. Actualizar `feature_list.json`.
3. Registrar riesgos o bloqueos sin resolver.
4. Dejar el repo limpio para que la próxima sesión pueda ejecutar `./init.sh` de inmediato.
