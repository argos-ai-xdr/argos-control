# ADR-011: Nivel de autonomía del MVP — hasta L3

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, SOC Analyst/Approver
* **Historia relacionada**: ARG-019, ARG-020, ARG-021

## Contexto

"AI-assisted" y "autónomo" no son sinónimos, y confundirlos en la propuesta crearía una expectativa de ejecución automática que el diseño de seguridad (ADR-003, ADR-005) no soporta ni debe soportar en el MVP.

## Decisión

El MVP llega hasta L3: observar, recomendar, dry-run, y aprobar+ejecutar de forma reversible. La autonomía L4 (ejecución sin intervención humana) queda fuera de alcance del MVP.

## Consecuencia

Cero ejecución crítica sin aprobación humana y sin rollback probado, en todo el horizonte septiembre-diciembre de 2026. Cualquier evolución hacia L4 requiere un ADR nuevo, no una ampliación silenciosa de scope.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC10 (HITL) y AC12 (Rollback) son la expresión operativa de este límite de autonomía.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-011).
