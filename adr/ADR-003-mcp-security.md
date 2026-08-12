# ADR-003: Seguridad de MCP (Model Context Protocol)

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1); versión de protocolo fijada a 2026-07-28
* **Decisores**: Product Owner/Arquitectura, SOAR/MCP Engineer, QA/Security Observer
* **Historia relacionada**: ARG-020, ARG-021

## Contexto

`argos-cyber-tools` expone herramientas de lectura y de respuesta (contención, aislamiento) a través de MCP para que el motor de recomendación (LangGraph/vLLM) las invoque. Un servidor MCP mal configurado, o un LLM con credenciales de ejecución directas, convertiría una alucinación del modelo en una acción real sobre el entorno.

## Decisión

Versión de MCP fijada a 2026-07-28. Gateway central obligatorio entre el LLM y cualquier servidor MCP. Autenticación mTLS/OIDC, `audience` exacta por servidor, `scope` por herramienta, y prohibición explícita de token passthrough.

## Consecuencia

Los servidores MCP no son de confianza implícita ni ejecutores directos: el LLM nunca llama a un ejecutor sin pasar por el gateway, la política OPA (ADR-005) y, para herramientas de riesgo alto, por aprobación humana (HITL).

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC09 (Tool use: argument/tool correctness, cero targets fuera de allowlist) y AC10 (HITL: cero ejecuciones sin aprobación) dependen de esta decisión.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-003).
