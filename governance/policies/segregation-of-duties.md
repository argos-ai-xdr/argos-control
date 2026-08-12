# Segregación de funciones

Regla base (documento maestro v0.5, 7.2 y 5.7): **quien genera una recomendación o ejecuta un playbook no puede autoaprobarla; QA/Security Observer puede bloquear un gate; ningún rol puede aprobar su propia excepción de seguridad.**

## Matriz de responsabilidades (no puede)

| Rol | Puede | No puede |
| --- | --- | --- |
| Product Owner/Arquitectura | Congelar alcance, aceptar trade-offs, aprobar desviaciones | Aprobar su propia excepción de seguridad sin revisión |
| Cyber-range Engineer | Construir/resetear escenario, fixtures y emulación ofensiva | Acceder a activos productivos o ampliar objetivos durante la demo |
| XDR Engineer | Telemetría, normalización, correlación y calidad de eventos | Modificar ground truth después de observar resultados |
| AI/Evaluation Engineer | Grafo LangGraph, schemas, harness, métricas y regresión | Usar el validation set para ajustar el sistema |
| SOAR/Platform Engineer | Playbook, policy enforcement, idempotencia y rollback | Ejecutar sin `approval_id` válido |
| SOC Analyst/Approver | Revisar evidencia, impacto y aprobar/rechazar la acción | Alterar runbook, política o evidencia durante la aprobación |
| Security Observer | Verificar gates, integridad del evidence pack y segregación | Operar el agente o aprobar la misma acción que evalúa |
| Demo Lead | Controlar guion, tiempos, contingencias y narrativa ejecutiva | Ocultar fallos o sustituir evidencia por capturas no trazables |

## Aplicación técnica

* MCP/gateway (ADR-003): el LLM no tiene credenciales de ejecución directas.
* OPA (ADR-005): la decisión de política es independiente del LLM y del ejecutor.
* Aprobación (contrato `Approval`): incluye `approver_id` distinto de `action_id.requested_by`; TTL y anti-replay.
* CODEOWNERS de cada repositorio: refleja esta matriz, no asigna un único aprobador universal.
