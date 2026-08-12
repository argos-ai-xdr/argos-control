# ADR-008: vLLM autogestionado con fallback determinista

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, AI/Evaluation Engineer
* **Historia relacionada**: ARG-019, DEP-06

## Contexto

El servicio de recomendación necesita un modelo de lenguaje para generar alternativas de remediación explicables, pero no puede depender de una API externa (soberanía, coste, disponibilidad) ni puede tener la única vía de decisión de autorización.

## Decisión

vLLM autogestionado. El modelo open-weight se selecciona tras evaluar licencia, seguridad, calidad y sizing. Existe un fallback determinista (reglas/plantillas) que funciona sin LLM.

## Consecuencia

No depende de una API externa. El modelo nunca decide autorización por sí mismo — esa decisión es de OPA (ADR-005) y del aprobador humano (HITL). Si el GPU/modelo soberano no está disponible a tiempo (DEP-06), el fallback determinista permite seguir operando sin bloquear la demo.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. AC09 (Tool use) y AC10 (HITL) no dependen de si la recomendación viene del LLM o del fallback determinista: ambos pasan por el mismo gate de política y aprobación.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-008) y sección 6.9 (DEP-06).
