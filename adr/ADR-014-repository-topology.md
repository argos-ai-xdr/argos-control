# ADR-014: Topología de repositorios — siete repositorios

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, Delivery Lead
* **Historia relacionada**: ARG-001

## Contexto

El documento maestro v0.5 (6.11) exige que "los repositorios y el release manifest separan plataforma, datos, No-RAG/Cyber, RAG/Chat, tooling, SmartOps, evidencia y gobierno", pero no fija el número exacto de repositorios. Dos extremos son indeseables: un monorepo mezclaría fronteras de seguridad muy distintas (p. ej. `argos-cyber-tools`, de máxima criticidad, junto a `argos-smartops`, una UI); una fragmentación por microservicio (uno por servicio de `argos-core`, uno por conector) multiplicaría el overhead de gobierno, CODEOWNERS y releases sin beneficio real para un equipo de 7,5 FTE.

## Decisión

Siete repositorios bajo la organización `argos-ai-xdr`:

1. `argos-control` — gobierno, ADR, RACI, releases, workflows reutilizables.
2. `argos-platform` — infraestructura declarativa (OpenTofu, Kubernetes, Argo CD, plataforma de identidad/observabilidad, cyber-range).
3. `argos-contracts-scenarios` — contratos de datos, fixtures y el escenario ARGOS-CYB-01.
4. `argos-core` — lógica funcional del XDR (normalizer, correlator, risk-engine, recommendation, etc.).
5. `argos-cyber-tools` — MCP gateway, tool catalog, ejecutores, sandbox, SOAR (máxima criticidad de seguridad).
6. `argos-validation` — evaluación independiente, harness, quality gates.
7. `argos-smartops` — API y UI de SmartOps (aprobación HITL, SOC handover).

Cada repositorio declara `repository.yaml` (dominio, criticidad, owner, dependencias) siguiendo la plantilla en `templates/repository/`.

## Consecuencia

Separa fronteras de seguridad reales (p. ej. `argos-cyber-tools` puede tener revisión reforzada y CODEOWNERS más estrictos que `argos-smartops`) y ciclos de despliegue distintos (infra vs. lógica de negocio vs. UI), sin fragmentar en exceso: un cambio típico de sprint (p. ej. ARG-019 Recommendation v1) toca como mucho dos o tres repos (`argos-core`, `argos-cyber-tools`, `argos-contracts-scenarios`), no siete.

Coste asumido: los cambios que cruzan contrato (p. ej. un campo nuevo en `SecurityEvent`) requieren coordinar PRs en `argos-contracts-scenarios` y en los repos consumidores, versionados según `compatibility/contracts.yaml`.

## Impacto sobre AC01-AC14

No aplica — decisión organizativa, no afecta directamente a los criterios de aceptación funcionales. Sí condiciona cómo se construye `evidence_manifest` (release manifest agrega el commit de cada uno de los 6 repos funcionales).

## Fuentes

Documento maestro v0.5, sección 6.11 (Definition of Done del paso 4) y discusión de bootstrap de `argos-ai-xdr` (2026-08-12).
