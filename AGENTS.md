# Project Agent Instructions

Este repositorio contiene la **Tarjeta digital** de Fahed Hermoza: una página estática de una sola vista, móvil-first, sin backend ni build, que agrupa su Perfil, sus Enlaces de contacto y un botón para guardar la Contacto (vCard).

## Read First

- `CONTEXT.md` — vocabulario del dominio (Tarjeta digital, Enlace, Perfil, Handle, Tagline, Contacto).
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

## Required Artifacts

- `feature_list.json`: fuente de verdad del estado de las features.
- `PROGRESS.md`: estado verificado actual y bitácora ligera de sesión.
- `init.sh`: camino estándar de arranque y verificación.

## Definition Of Done

Una feature está terminada solo cuando todo lo siguiente es cierto:

- el comportamiento objetivo está implementado,
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
