# ADR-061: SemanticConflict y Authority precedence (Fase K)

* **Estado**: RESUELTO PARA BASELINE
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura
* **Historia relacionada**: extiende `asset_reconciler.reconcile()` (ARG-010) — no lo duplica

## Contexto

`asset_reconciler.reconcile()` (ARG-010) ya detectaba conflictos entre
fuentes (`{field, values: {source: value}}`) pero los resolvía con
"última fuente en la lista gana" — sin política de autoridad gobernada.
El prompt exige lo contrario explícitamente: "no escoger automáticamente
una versión salvo que exista una regla determinista de precedencia ya
gobernada", con `winning_source/rejected_source/rule/reason_code/
evidence_refs` conservados en cada resolución.

## Decisión

`argos-core/services/semantic_conflict` implementa `resolve_conflict`:
función pura, determinista. Sin `authority_ranking` → siempre
`REQUIRES_AUTHORITY` (nunca elige arbitrariamente). Con política:
autoridad estrictamente mayor gana (`CONFLICT`, `rule=
"authority_precedence"`); empate de autoridad con mismo valor → resuelto
por acuerdo; empate de autoridad con valores distintos → desempate por
`observed_at` más reciente (`rule="authority_precedence+freshness_tiebreak"`);
empate total → `REQUIRES_AUTHORITY`. La clasificación (`TEMPORAL/
AUTHORITY/SEMANTIC/CLASSIFICATION/IDENTITY`) la decide el LLAMANTE
explícitamente — nunca se infiere del contenido.

`asset_reconciler.reconcile()`/`build_asset_snapshot_payload` se
EXTIENDEN con un parámetro `authority_ranking: dict[str, int] | None =
None` — sin él, comportamiento idéntico al anterior (los 6 tests
originales pasan sin modificación); con él, cada conflicto se resuelve
vía `resolve_conflict` y el campo toma el valor ganador, u se omite del
merge si la resolución es `REQUIRES_AUTHORITY` (nunca un valor
arbitrario).

## Consecuencia

* No se duplica la detección de conflictos ya existente en
  `asset_reconciler` — se reutiliza y se le añade la pieza que le
  faltaba (política de resolución gobernada).
* Callers existentes de `reconcile()`/`build_asset_snapshot_payload` sin
  `authority_ranking` no ven ningún cambio de comportamiento.

## Impacto sobre AC01-AC14

No aplica directamente.

## Fuentes

`argos-core/services/semantic_conflict/{__init__.py,README.md}`,
`argos-core/services/asset_reconciler/__init__.py` (extendido),
`argos-core/tests/unit/{test_semantic_conflict.py,test_asset_reconciler.py}`.
