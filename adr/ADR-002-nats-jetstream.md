# ADR-002: NATS JetStream como bus de eventos MVP

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, Platform/SRE
* **Historia relacionada**: ARG-001, ARG-015

## Contexto

Los ocho servicios de `argos-core` y los conectores de telemetría necesitan un bus de eventos autogestionable, desplegable en OSC/local, con garantías suficientes para no perder eventos de seguridad sin la complejidad operativa de un stack tipo Kafka.

## Decisión

NATS JetStream para el bus de eventos del MVP: entrega at-least-once, consumidores durables, reintento (retry), dead-letter queue (DLQ) y deduplicación por `event_id`.

## Consecuencia

Menor complejidad operativa que alternativas tipo Kafka/Pulsar. A cambio, todos los consumidores (normalizer, correlator, evidence-writer, etc.) deben ser idempotentes: un reintento o una entrega duplicada no puede producir un `Incident` o una `ActionResult` distintos.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC13 (Resiliencia: reanudación sin acción duplicada, idempotency violations = 0) depende directamente de esta decisión.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-002).
