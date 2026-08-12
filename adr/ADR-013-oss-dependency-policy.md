# ADR-013: Política de dependencias open source

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, QA/Security Observer
* **Historia relacionada**: ARG-002 (transversal a todo el ciclo de vida)

## Contexto

Sin una política explícita, cualquier work package puede introducir una dependencia comercial que, si falla, bloquea la demo o la aceptación — algo incompatible con el requisito de soberanía y coste cero de licencia de la propuesta.

## Decisión

Solo se aceptan dependencias con código y licencia verificables, autogestionables (self-hosting), con SBOM, referenciadas por digest, cubiertas por un scanner, con owner asignado y sustituto identificado. Cualquier excepción tiene fecha de caducidad obligatoria.

## Consecuencia

Ningún componente comercial puede bloquear la demo ni la aceptación. Toda nueva dependencia pasa por el checklist de Definition of Ready (licencia, versión/digest, SBOM, CVEs críticos, owner, alternativa de sustitución) antes de entrar en una historia.

## Impacto sobre AC01-AC14

No aplica — decisión fundacional. Condiciona qué puede declararse P0 en el backlog y qué se puede desplegar en `argos-platform`.

## Fuentes

Documento maestro v0.5, sección 6.6 (ADR-013) y sección 6.10.1 (Definition of Ready).
