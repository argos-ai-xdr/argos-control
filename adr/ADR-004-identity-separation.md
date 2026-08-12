# ADR-004: Separación de identidades (usuarios, workloads, secretos)

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, Platform/SRE
* **Historia relacionada**: ARG-001, ARG-003

## Contexto

La plataforma tiene cuatro tipos de identidad distintos que no deben compartir mecanismo: analistas humanos, agentes/servicios (workloads), el gateway MCP y las herramientas que este invoca, y los secretos de corta duración que todos ellos consumen.

## Decisión

Keycloak para usuarios humanos (SmartOps, aprobación HITL). SPIFFE/SPIRE para identidad de workloads (mTLS entre servicios). OpenBao para secretos de corta duración (tokens, credenciales de conectores).

## Consecuencia

Separa identidades humanas, agentes, gateways y tools: comprometer una no compromete automáticamente las otras tres. Ningún servicio usa credenciales estáticas de larga duración.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. Sustenta AC09 y AC10 (segregación de quién puede aprobar frente a quién ejecuta).

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-004).
