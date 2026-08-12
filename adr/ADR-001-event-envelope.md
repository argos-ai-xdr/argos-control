# ADR-001: ARGOS Event Envelope v1

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura (POA), con consulta a PSE/XDR/SME
* **Historia relacionada**: ARG-001, ARG-004

## Contexto

Los servicios de `argos-core` (normalizer, correlator, risk-engine, recommendation) y los conectores de `argos-cyber-tools` necesitan un formato común para transportar eventos de seguridad sin obligar a cada fuente (Wazuh, Falco, Hubble, Kubernetes audit, MISP) a reescribir su modelo nativo. Imponer un esquema completo de reescritura perdería trazabilidad de origen y encarecería cada nuevo adaptador.

## Decisión

ARGOS Event Envelope v1 alineado con OCSF (Open Cybersecurity Schema Framework). El payload nativo de la fuente se conserva por referencia (`native_ref`), no se reescribe. El mapping a ECS se aplica específicamente en la ruta Wazuh/OpenSearch.

## Consecuencia

Evita imponer un esquema completo de reescritura y conserva la trazabilidad de origen. Cada adaptador debe producir el envelope OCSF-aligned más una referencia verificable al evento nativo (criterio AC06).

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC06 (Detección) y AC08 (Grounding CTI) dependen de que el envelope incluya `native_ref` y fuente verificable.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-001) y sección 5.5 (contrato `SecurityEvent`).
