# Gates G0-G7

Fuente: documento maestro v0.5, secciones 7.4 y 7.4.1. Un gate rojo bloquea la promoción; no se compensa con una demo manual.

| Sprint | Objetivo | Entregable integrado | Gate de salida | Hito de demo |
| --- | --- | --- | --- | --- |
| S1 | Scope Gate | Repos/releases, SBOM/firma, cyber-range reset/kill switch | **G0**: owners, accesos, calendario, P0 y DoR aprobados | Despliegue limpio y reset reproducible |
| S2 | Data & Contract Gate | 10 contratos v1, F01-F09, harness y tests producer/consumer | **G1**: schemas compatibles, procedencia/licencia y ground truth | Replay de fixture y reporte AC |
| S3 | C-06 | Inventario, SBOM/findings y priorización ESP+KEV+EPSS | **G2**: ranking explica hechos, fuentes y hashes; sin inferencias falsas | Activo a remediación recomendada |
| S4 | C-07 | Exposición, RBAC, ruta controlada y validación en range | **G3**: allowlist, autorización, reset y cero egress no previsto | Attack path reproducible y seguro |
| S5 | C-08 detección | Wazuh/Falco/Hubble/Audit, MISP, Incident v1 y timeline | **G4**: timestamps/IDs, precisión/recall y trazabilidad a ground truth | Incidente correlacionado extremo a extremo |
| S6 | HITL Response | Recommendation v1, OPA, approval, Shuffle y rollback | **G5**: no execute sin aprobación; TTL, anti-replay, idempotencia y rollback | Aprobar/rechazar y contención reversible |
| S7 | Release Candidate | CP00-CP13, F09 adversarial, resiliencia, backup/restore | **G6**: feature freeze, suites P0 verdes y cero defecto crítico abierto | Ensayo completo con fallo y recuperación |
| S8 | Acceptance Gate | AC01-AC14, DRR, as-built, runbooks, evidence pack y PI3 | **G7**: reproducción independiente, evidencias firmadas y aceptación | Demo final y transferencia |

## Criterios BLOCKED y autoridad del gate

* **G0-G1** quedan BLOCKED si faltan owner, licencia/procedencia, acceso/fallback o contrato versionado; no se compensa con una demo manual.
* **G2-G4** quedan BLOCKED si el resultado no se compara con ground truth, si no existe trazabilidad `event_id`/`run_id`, o si una integración emulada se presenta como real.
* **G5** queda BLOCKED ante cualquier ejecución sin `approval_id` válido, `plan_hash` inmutable, target allowlist, TTL, segregación de funciones, verificación o rollback probado.
* **G6-G7** quedan BLOCKED con CVE crítica explotable sin excepción aprobada, defecto crítico, pérdida de evidencia, dependencia comercial obligatoria, regresión sobre umbral o incapacidad de reconstruir el release.

QA/Security Observer puede bloquear cualquier gate; Product Owner/Arquitectura acepta alcance; SOC aprueba la operación. **Ningún rol puede autoaprobar una excepción de la que sea ejecutor.**

## Hitos y puntos de decisión (M0-M8)

| Hito | Fecha | Decisión verificable | Consecuencia si no se cumple |
| --- | --- | --- | --- |
| M0 | 14 sep 2026 | Scope/Access baseline y release 0.1 | Sin G0 no se compromete forecast |
| M1 | 28 sep 2026 | Contratos y capacidad observada S1-S2 | Rebaselinar P0, equipo y rango de entrega |
| M2 | 12 oct 2026 | C-06 demostrable | Autoriza C-07 o activa fallback de adapters |
| M3 | 26 oct 2026 | C-07 seguro y reproducible | Autoriza telemetría ofensiva controlada |
| M4 | 09 nov 2026 | C-08 detección e Incident v1 | Congela schema crítico para respuesta |
| M5 | 23 nov 2026 | HITL+SOAR reversible | Go/no-go de integración final |
| M6 | 07 dic 2026 | Release Candidate y feature freeze | Solo defectos P0 hasta aceptación |
| M7 | 21 dic 2026 | Aceptación y handover | Entrega o plan de remediación fechado |
| M8 | 31 dic 2026 | Archivo, transferencia y cierre | Baseline PI3 y lecciones aprendidas |

Ver criterios de aceptación completos en `../../project/acceptance/`.
