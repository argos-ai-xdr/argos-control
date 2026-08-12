# Aceptación

`acceptance-criteria.yaml` es la fuente autoritativa de AC01-AC14 (documento maestro v0.5, 5.6). `argos-validation` implementa los evaluadores que producen `run_summary.json` con el resultado de cada criterio; este repositorio solo define el umbral y la regla de decisión.

## Evidence pack requerido (5.8)

* `manifest.json` — versión, commit, imágenes/digests, datasets, políticas, prompts, runbooks y hashes de todos los artefactos.
* `run_summary.json` — resultado global, AC01-AC14, quality gates, warnings, expected blocks y desviaciones.
* `events.ndjson` y trazas OTLP/JSON correlacionadas por `run_id`, `trace_id`, `incident_id`, `recommendation_id` y `action_id`.
* Snapshots de MISP, ATT&CK, KEV, EPSS y CVE realmente utilizados (nunca enlaces online sin captura).
* Decisiones de política, dry-run, aprobación, ejecución, verificación y rollback con timestamps y actores.
* Informe HTML offline y vista SmartOps con narrativa, evidencia enlazada, métricas y limitaciones conocidas.
* Paquete SOC filtrado según TLP/clasificación, con comprobación automática de campos prohibidos.

Ningún criterio crítico admite waiver (ver `no_waiver_for` en `acceptance-criteria.yaml`).
