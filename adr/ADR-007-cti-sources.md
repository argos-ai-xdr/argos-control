# ADR-007: Fuentes CTI — MISP P0, IBM X-Force excluido

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura
* **Historia relacionada**: ARG-016

## Contexto

La correlación y priorización (risk-engine, correlator) necesitan inteligencia de amenazas (IoCs, ATT&CK, KEV, EPSS, CVE/NVD) con procedencia verificable y coste de licencia predecible, desplegable de forma soberana sin depender de una API comercial obligatoria.

## Decisión

MISP como núcleo P0, más snapshots versionados de ATT&CK, KEV, EPSS y CVE/NVD. OpenCTI Community queda como opción, no obligatoria. IBM X-Force queda excluido del diseño.

## Consecuencia

Aceptación offline (sin dependencia de red durante la ejecución de aceptación), coste cero de licencia y procedencia verificable de cada IoC/KEV/EPSS/ATT&CK usado.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC08 (Grounding CTI: fuente, snapshot, timestamp y evidence_ref obligatorios; inventados = 0) depende de esta decisión.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-007) y sección 1 (resumen ejecutivo: política open source y soberana).
