# ADR-059: Temporal Knowledge (Fase K)

* **Estado**: RESUELTO PARA BASELINE
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura
* **Historia relacionada**: `architecture/v0.6.25-gap-matrix.md` §13 (Temporal Knowledge marcado NO EXISTE como motor genérico)

## Contexto

El prompt exige poder responder "¿qué sabía ARGOS en el momento T?" sin
usar información incorporada después de T. El único precedente real
(`evaluators/drift`, ARG-010) compara as-designed/as-built de un activo
puntualmente, sin ser un motor temporal genérico sobre cualquier
entidad/atributo.

## Decisión

`argos-core/services/temporal_knowledge` implementa `TemporalFact` +
`TemporalKnowledgeBase.query_at(entity_id, attribute, T)`. Distinción
central: la consulta es **epistémica, no ontológica** — un hecho con
`observed_at > T` nunca se devuelve para T, incluso si su `valid_from`
lo haría parecer aplicable. `supersede()` nunca borra ni reescribe: marca
`superseded_at` en una copia, preservando la reconstrucción para
cualquier T anterior al supersedeo. Sin método de borrado en la API
pública (`add_fact`, `supersede`, `all_facts`, `query_at`, `history_for`
son los únicos métodos públicos).

## Consecuencia

* `future_information_leakage = 0` queda probado explícitamente
  (`test_future_information_leakage_is_zero`).
* No sustituye a `evaluators/drift` (ARG-010) — ese sigue siendo el
  mecanismo real de comparación as-designed/as-built de activos;
  `temporal_knowledge` es un motor genérico distinto, reutilizable por
  `mission_context`/`semantic_graph`.

## Impacto sobre AC01-AC14

No aplica.

## Fuentes

`argos-core/services/temporal_knowledge/{__init__.py,README.md}`,
`argos-core/tests/unit/test_temporal_knowledge.py`,
`architecture/v0.6.25-gap-matrix.md` §13.
