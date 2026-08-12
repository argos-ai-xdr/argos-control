# ADR-009: Observabilidad soberana (OTel, Prometheus/Grafana, OpenSearch)

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, Platform/SRE
* **Historia relacionada**: ARG-001, ARG-003

## Contexto

Cada decisión del sistema (detección, correlación, recomendación, aprobación, ejecución) debe poder trazarse extremo a extremo sin depender de un SaaS de observabilidad externo, y sin filtrar contenido sensible del razonamiento del modelo.

## Decisión

OpenTelemetry Collector para trazas y métricas, Prometheus/Grafana OSS para el plano de métricas y dashboards, OpenSearch para el índice de logs/eventos. Correlación transversal por `run_id`/`trace_id`.

## Consecuencia

Observabilidad soberana, autogestionable en OSC/local. No se almacena chain-of-thought del modelo en trazas ni logs — solo entradas, salidas estructuradas y decisiones.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC01 (Reproducibilidad) y AC14 (trace completeness >= 0.95) dependen de esta decisión.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-009).
