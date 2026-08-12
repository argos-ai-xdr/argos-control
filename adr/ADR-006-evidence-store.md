# ADR-006: OpenSearch + Ceph RGW como almacén de evidencia

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, Platform/SRE, QA/Security Observer
* **Historia relacionada**: ARG-001, ARG-026

## Contexto

Toda la cadena de aceptación (AC01-AC14) depende de que la evidencia generada durante una demo o una ejecución sea reproducible, no editable a posteriori y consultable. Se necesita separar el índice consultable del almacenamiento de objetos.

## Decisión

OpenSearch para el índice consultable de eventos, incidentes y decisiones. Ceph RGW para el almacenamiento de objetos (payloads nativos, capturas, snapshots). Cada manifiesto de evidencia se firma y se hashea con SHA-256; existe política de retención y una prueba de restore.

## Consecuencia

Comportamiento WORM lógico sobre los objetos de evidencia según la capacidad disponible en OSC; el agente (LangGraph/vLLM) no tiene permisos de escritura ni de modificación sobre la evidencia ya escrita por `evidence-writer`.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC14 (Evidencia/SOC: trace completeness >= 0.95, hashes válidos = 1.00) depende directamente de esta decisión.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-006).
