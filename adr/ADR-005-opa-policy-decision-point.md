# ADR-005: OPA como Policy Decision Point

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, SOAR/MCP Engineer
* **Historia relacionada**: ARG-020

## Contexto

La decisión de si una acción de respuesta puede ejecutarse (o solo simularse en dry-run, o requiere aprobación) no puede residir dentro del LLM ni estar dispersa en cada ejecutor: debe ser verificable, versionada y auditable independientemente del modelo.

## Decisión

OPA (Open Policy Agent) como Policy Decision Point. Las decisiones posibles son `DENY`, `ALLOW_DRY_RUN` y `APPROVAL_REQUIRED`. Gatekeeper se usa además en el plano de admisión de Kubernetes.

## Consecuencia

La política queda comprobable fuera del LLM y versionada como código (`argos-cyber-tools/policies/opa/`). Todo `PolicyDecision` es reproducible: mismos inputs producen la misma decisión.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC10 (HITL) y AC11 (Contención) dependen de que la política bloquee de forma determinista.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-005).
