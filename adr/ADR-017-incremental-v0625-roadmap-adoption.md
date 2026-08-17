# ADR-017: Adopción incremental de la hoja de ruta v0.6.25.x (Fases A→L)

* **Estado**: RESUELTO PARA BASELINE — alcance de fases confirmado; alcance de contratos explícitamente diferido (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Product Owner/Arquitectura (confirmación del usuario tras revisar `architecture/v0.6.25-gap-matrix.md`)
* **Historia relacionada**: Ninguna ARG-001..028 existente cubre este alcance. No se crea ARG-029+ todavía — cada fase (Fase H en adelante) debe justificar su propia historia cuando se aborde, no antes (ver `architecture/v0.6.25-gap-matrix.md`, §62-64).

## Contexto

La propuesta técnica evolucionó (v0.6.25 → v0.6.25.4) para especificar una
arquitectura ampliada — Governed Agentic RAG, Deep Assurance, Continuous
Trust, Sovereign Safety Kernel, Semantic Trust Fabric — que el propio
documento maestro declara explícitamente **"SPECIFIED / PREPARED - NOT
EXECUTED"**. Se recibió un "prompt maestro" pidiendo revisar si esa
arquitectura está implementada y, si no, construirla.

`architecture/v0.6.25-gap-matrix.md` (commit previo a este ADR) confirma
por inspección directa de los 7 repos que la mitad "operativa" de la
cadena de decisión (Incident→Recommendation→PolicyDecision→Approval→
Execute→Verify→Rollback→Evidence) es real y probada, y la mitad "de
aseguramiento" (Safety Kernel, SafetyEnvelope, Independent Verifier,
RuntimeTrustContext, Transparency Log, Semantic Trust Fabric, Federation)
no existe en absoluto. Construir las ~70 secciones del prompt de golpe
— incluyendo 50 ADR y ~32 contratos v1 nuevos — no es una iteración
razonable ni honesta.

Opciones presentadas al usuario: (1) construir solo el Safety Kernel
primero (mayor valor de seguridad por esfuerzo, determinista, no
depende de subsistemas inexistentes); (2) seguir el orden de fases
A→L que el propio prompt propone en su sección 65; (3) detener aquí y
quedarse con el análisis; (4) resolver primero la tensión de los 32
contratos nuevos frente a la decisión ya ratificada de "10 contratos
v1 cerrados" (documento maestro §6.5).

## Decisión

Se adopta la opción (2): avanzar **fase por fase, en el orden A→L que
define el propio prompt maestro** (§65), construyendo en cada fase
únicamente lo que sea real y verificable — nunca scaffolding vacío para
un subsistema que la fase todavía no sustenta.

Fase A ("Control + Contracts") se interpreta de forma restringida: se
construye el gobierno documental (`assurance/`, `ai-governance/`) con
contenido REAL sobre el MVP ya existente, pero **no se crean los ~32
contratos v1 nuevos de la sección 5 del prompt en esta fase** — esa
decisión queda explícitamente fuera del alcance de este ADR (ver
Consecuencia).

## Consecuencia

* Las fases D/E/F (C-06/C-07/C-08) ya están sustancialmente cubiertas
  por el MVP existente — no se reconstruyen, solo se documentan sus
  huecos reales frente al prompt (ya hecho en el gap matrix).
* Fase H (Safety Kernel/SafetyEnvelope/PolicyDecision/Approval) es la
  primera pieza de aseguramiento nueva con valor de seguridad
  inmediato, y se abordará tan pronto el gobierno de Fase A tenga una
  base mínima real.
* **Los ~32 contratos v1 nuevos de la sección 5 del prompt NO se crean
  todavía.** Añadirlos contradice la decisión ya ratificada de que los
  10 contratos v1 (`argos-contracts-scenarios`) son un conjunto cerrado
  (documento maestro §6.5), validada activamente en CI por
  `argos-validation`/`argos-contracts-scenarios`. Cuando una fase
  concreta necesite un contrato nuevo real (p. ej. `SafetyEnvelope v1`
  para Fase H), se evaluará y ratificará EN ESE MOMENTO, contrato por
  contrato, con su propio ADR — no como una expansión en bloque
  decidida de antemano sin que exista todavía el código que lo
  necesite.
* No se reestructuran los 7 repos según los árboles de directorios de
  las secciones 3-6/15/39/49 del prompt de una sola vez — cada
  directorio nuevo (p. ej. `argos-core/src/safety_kernel/`) se crea
  cuando la fase correspondiente empieza a construirse de verdad, no
  antes.
* Este ADR no declara ninguna capacidad de v0.6.25.x como implementada
  — solo fija el ORDEN y el CRITERIO ("nunca scaffolding vacío") con el
  que se abordará lo que sí se construya.

## Impacto sobre AC01-AC14

No aplica — decisión de secuenciación de roadmap, no de un criterio de
aceptación existente. Ningún AC01-AC14 se relaja ni se sustituye.

## Fuentes

Prompt maestro de arquitectura objetivo (recibido 2026-08-17),
`architecture/v0.6.25-gap-matrix.md`, documento maestro v0.6.25.4
(declaración "SPECIFIED / PREPARED - NOT EXECUTED" para Governed Agentic
RAG, Deep Assurance, Continuous Trust, Sovereign Safety Kernel/Trust
Anchor, Semantic Trust Fabric), documento maestro §6.5 (conjunto cerrado
de 10 contratos v1).
