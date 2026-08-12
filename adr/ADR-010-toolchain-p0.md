# ADR-010: Toolchain P0 mínima

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura
* **Historia relacionada**: ARG-001 a ARG-028 (aplica transversalmente)

## Contexto

La arquitectura objetivo v0.9 lista muchas más capacidades de las que caben en un MVP de 8 sprints. Sin un límite explícito de toolchain, cada work package tiende a incorporar herramientas nuevas que no se llegan a integrar ni a evaluar a tiempo.

## Decisión

Toolchain P0 mínima y cerrada para el MVP: Wazuh, Falco, Cilium/Hubble, Trivy/OpenVAS, MISP, Shuffle, OPA y OpenTelemetry.

## Consecuencia

Toda herramienta adicional a esta lista requiere valor medido, licencia verificada y coste operativo evaluado antes de incorporarse (no se añade "porque existe"). Reduce superficie de mantenimiento y de aprendizaje del equipo de 7,5 FTE.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional; acota qué integraciones pueden declararse `REAL` frente a `EMULATED`/`PLANNED` en `argos-validation`.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-010).
