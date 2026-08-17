# ADR-060: MissionContext y blast radius técnico/operacional/misión (Fase K)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura
* **Historia relacionada**: `architecture/v0.6.25-gap-matrix.md` §12 (Mission Context, NO EXISTE)

## Contexto

El prompt exige distinguir `technical_blast_radius`/
`operational_blast_radius`/`mission_blast_radius`, con el invariante
"UNKNOWN critical mission impact != zero impact". `argos-cyber-tools/
graph/blast_radius.py` (ARG-014) ya calcula el radio técnico real
(recuento de servicios/subjects afectados vía NetworkPolicy/RoleBinding)
— no existe la capa de misión que lo extienda.

## Decisión

`argos-core/services/mission_context` implementa `MissionContext`
(criticality, crown_jewel, acceptable_degradation, maximum_outage,
recovery_priority, dependencies) y `assess_blast_radius(mission_context,
technical_affected_count, technical_evidence_refs)`. **No reimplementa
el cálculo técnico** — `technical_affected_count`/`technical_evidence_refs`
los suministra el llamante (el resultado real de `graph.blast_radius.py`,
mismo patrón que `safety_kernel.SafetyCheckInput.observed_blast_radius_count`).

**Invariante aplicado en código, no solo documentado**: sin
`MissionContext` para el activo, o con `criticality`/`crown_jewel` no
evaluados, o sin `technical_affected_count`, el resultado es
`INSUFFICIENT_CONTEXT` — nunca `NONE`/`LOW` por defecto. Un
`technical_affected_count=0` con contexto completo SÍ es `NONE` real
(dato conocido que vale cero, distinto de dato ausente).

## Consecuencia

* No se crea un segundo motor de blast radius — `graph/blast_radius.py`
  (ARG-014) sigue siendo la única fuente del recuento técnico real.
* Clasificación mission_blast_radius: `crown_jewel=True` + impacto
  técnico > 0 → `CRITICAL` siempre; si no, escala por `criticality`
  (`high`/`critical`→`HIGH`, `medium`→`MEDIUM`, `low`→`LOW`).
* `assess_blast_radius` nunca decide autorización — ver ADR-062 (consumo
  por `safety_kernel`).

## Impacto sobre AC01-AC14

No aplica directamente.

## Fuentes

`argos-core/services/mission_context/{__init__.py,README.md}`,
`argos-core/tests/unit/test_mission_context.py`,
`argos-cyber-tools/graph/blast_radius.py` (ARG-014, fuente real del
recuento técnico), `architecture/v0.6.25-gap-matrix.md` §12.
