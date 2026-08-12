# Contribuir a argos-control

Este repositorio gobierna al resto de la organización `argos-ai-xdr`. Los cambios aquí tienen efecto sobre los siete repositorios.

## Flujo de trabajo

1. Toda historia debe existir como issue `ARG-###` en `project/backlog/backlog.yaml` (o un `story.yaml` nuevo) antes de abrir una rama.
2. Rama de trabajo: `feat/ARG-###-descripcion-corta`, `fix/...`, `adr/ADR-0NN-titulo`.
3. Pull request obligatorio contra `main`. Sin push directo, force-push ni borrado de `main`.
4. Todo PR debe:
   - enlazar la historia `ARG-###` correspondiente;
   - pasar los checks de CI (`reusable-*` workflows);
   - respetar `CODEOWNERS` — al menos un revisor del rol propietario de la carpeta afectada.
5. Todo cambio arquitectónico (nuevo componente, cambio de contrato, cambio de topología) requiere un ADR nuevo o la actualización explícita de uno existente con nuevo estado y consecuencia.

## Tipos de cambio con revisión reforzada

* `adr/` — cambia una decisión RESUELTA PARA BASELINE MVP: requiere análisis de impacto sobre AC01-AC14 y aprobación de Product Owner/Arquitectura.
* `governance/gates/` — cambia un criterio BLOCKED: requiere aprobación de QA/Security Observer.
* `releases/schema/` — cambia el schema del release manifest: requiere validar que todos los manifiestos existentes siguen siendo válidos o se migran.
* `compatibility/contracts.yaml` — cambia una regla de compatibilidad (PATCH/MINOR/MAJOR): requiere coordinación con `argos-contracts-scenarios`.

## Estilo

* Markdown para documentos, YAML para datos estructurados, JSON Schema para validación.
* Fechas en UTC, formato RFC 3339.
* Sin secretos, credenciales, tokens ni datos de clientes en ningún archivo.

Ver también `governance/policies/` y `SECURITY.md`.
