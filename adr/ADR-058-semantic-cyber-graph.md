# ADR-058: Semantic Cyber Graph (Fase K)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura (mismo criterio de ADR-051 y siguientes: construir solo lo real y verificable)
* **Historia relacionada**: continuación del roadmap A→L adoptado en ADR-051; identificado en `architecture/v0.6.25-gap-matrix.md` §11

## Contexto

El prompt maestro pide un "Semantic Cyber Graph": entidades y relaciones
tipadas (`CyberSemanticEntity`/`SemanticRelation`) con procedencia real
por relación (`source_id/source_type/source_version/observed_at/
valid_from/valid_until/evidence_ref/authority`), explícitamente sin
generación por LLM. `architecture/v0.6.25-gap-matrix.md` §11 confirmaba
que no existía nada de esto — el grafo RBAC/red de `argos-cyber-tools/
graph` (ARG-011..014) modela un subconjunto muy distinto (Subject/Role/
Service/NetworkPolicy), no un modelo semántico de 15 tipos de entidad.

## Decisión

`argos-core/services/semantic_graph` implementa `CyberSemanticEntity`/
`SemanticRelation` con los tipos y relaciones mínimos del prompt.
**Construcción exclusivamente determinista**: cada entidad se construye
desde un contrato v1 ya validado (`AssetSnapshot`, `VulnerabilityFinding`,
`Incident`) — nunca inventada. `SemanticGraph.add_relation` rechaza
relaciones cuyos extremos no existan en el grafo (`DanglingRelation`).
`snapshot_hash()` reutiliza el mismo mecanismo de hash agregado
determinista de `evidence_root` (ADR-057) — mismo conjunto de
entidades/relaciones, sin importar orden de inserción, produce el mismo
hash.

Sin contrato v1 nuevo — nada fuera de `argos-core` lo consume todavía
(mismo criterio que `ReplayCapsule`/`VerificationResult`/`EvidenceRoot`).

## Consecuencia

* No se rediseña `argos-cyber-tools/graph` (ARG-011..014) — sigue siendo
  la fuente real de hechos RBAC/red; `semantic_graph` los consumiría
  como hechos suministrados por el llamante si se necesitara en el
  futuro (mismo patrón que `safety_kernel.SafetyCheckInput`).
* No se crea ARG-029+: extensión directa del roadmap ya adoptado.

## Impacto sobre AC01-AC14

No aplica — capa de representación adicional, ningún AC existente se
relaja ni se sustituye.

## Fuentes

`argos-core/services/semantic_graph/{__init__.py,README.md}`,
`argos-core/tests/unit/test_semantic_graph.py`,
`architecture/v0.6.25-gap-matrix.md` §11.
