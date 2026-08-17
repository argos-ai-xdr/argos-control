# ADR-063: Integración de evidencia de decisiones de misión con Fase J (Fase K)

* **Estado**: RESUELTO PARA BASELINE
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura
* **Historia relacionada**: cierra K9 del prompt maestro, reutilizando `evidence_root`/`evidence_writer` (ADR-057)

## Contexto

El prompt exige (K9) que todo cálculo de contexto/impacto de misión
produzca artefactos integrables con la infraestructura de evidencia ya
real de Fase J, y (invariante cruzado K) que un cambio posterior al
grafo o al modelo de misión NO reescriba lo que ARGOS sabía en el
momento de la decisión original.

## Decisión

`argos-core/services/mission_context/evidence.py` implementa
`MissionDecisionRecord` (payload puro: `semantic_graph_snapshot_hash`,
`mission_context_hash`, `temporal_query_time`, `source_refs`,
`authority_resolution`, `semantic_conflicts`, `unknowns`,
`blast_radius_result`, `safety_kernel_state`/`reason`) y
`record_mission_decision_evidence`, que ancla ese payload **reutilizando
literalmente** `evidence_writer.EvidenceWriter.write_bytes` y
`evidence_root.build_evidence_root` — **sin mecanismo de evidencia
paralelo**.

`semantic_graph_snapshot_hash`/`mission_context_hash` son hashes de
CONTENIDO en el momento de la decisión — un cambio posterior al grafo en
memoria (nuevas entidades/relaciones) produce un `snapshot_hash()`
distinto, pero el valor ya escrito en el `MissionDecisionRecord`
existente, y el `EvidenceManifest`/`EvidenceRoot` que lo ancla, nunca se
regeneran ni se sobrescriben — probado explícitamente en el vertical
slice (`test_full_semantic_mission_vertical_slice`, paso 10).

## Consecuencia

* Fase K no crea un segundo `EvidenceManifest`/`EvidenceRoot` — consume
  el de Fase J tal cual.
* El vertical slice completo (`asset_reconciler` → `semantic_graph` →
  `temporal_knowledge` → `semantic_conflict` → `mission_context` →
  `safety_kernel` → `evidence_root`/`transparency_log`) se demuestra en
  un único test de integración real, sin datos inventados en ningún
  tramo — usa `AssetSnapshot` real construido por `asset_reconciler`.

## Impacto sobre AC01-AC14

Sustenta AC14 (evidencia) con un caso de uso adicional real sobre el
mismo mecanismo.

## Fuentes

`argos-core/services/mission_context/evidence.py`,
`argos-core/tests/integration/test_semantic_mission_vertical_slice.py`,
`adr/ADR-057-evidence-root-and-local-transparency-log.md`.
