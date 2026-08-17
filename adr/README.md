# Registro de decisiones de arquitectura (ADR)

Todas las decisiones ADR-001 a ADR-013 provienen del documento maestro v0.5 (sección 6.6) y están **RESUELTAS PARA BASELINE MVP**: cambiarlas exige un nuevo ADR, análisis de impacto sobre AC01-AC14 y plan de migración. ADR-014 a ADR-016 son decisiones de gobierno de repositorios tomadas al arrancar `argos-ai-xdr`.

| ADR | Título | Estado |
| --- | --- | --- |
| [ADR-001](ADR-001-event-envelope.md) | ARGOS Event Envelope v1 (OCSF) | RESUELTO |
| [ADR-002](ADR-002-nats-jetstream.md) | NATS JetStream como bus MVP | RESUELTO |
| [ADR-003](ADR-003-mcp-security.md) | Seguridad de MCP | RESUELTO |
| [ADR-004](ADR-004-identity-separation.md) | Separación de identidades (Keycloak/SPIFFE/OpenBao) | RESUELTO |
| [ADR-005](ADR-005-opa-policy-decision-point.md) | OPA como Policy Decision Point | RESUELTO |
| [ADR-006](ADR-006-evidence-store.md) | OpenSearch + Ceph RGW como almacén de evidencia | RESUELTO |
| [ADR-007](ADR-007-cti-sources.md) | Fuentes CTI — MISP P0, sin IBM X-Force | RESUELTO |
| [ADR-008](ADR-008-vllm-fallback.md) | vLLM autogestionado con fallback determinista | RESUELTO |
| [ADR-009](ADR-009-observability.md) | Observabilidad soberana (OTel/Prometheus/OpenSearch) | RESUELTO |
| [ADR-010](ADR-010-toolchain-p0.md) | Toolchain P0 mínima | RESUELTO |
| [ADR-011](ADR-011-autonomy-level.md) | Nivel de autonomía del MVP — hasta L3 | RESUELTO |
| [ADR-012](ADR-012-product-naming.md) | Denominación: AI-assisted XDR | RESUELTO |
| [ADR-013](ADR-013-oss-dependency-policy.md) | Política de dependencias open source | RESUELTO |
| [ADR-014](ADR-014-repository-topology.md) | Topología de repositorios — siete repositorios | RESUELTO |
| [ADR-015](ADR-015-cicd-gitops.md) | CI/CD centralizado y despliegue GitOps | RESUELTO |
| [ADR-016](ADR-016-evidence-storage-policy.md) | Política de almacenamiento de evidencia fuera de Git | RESUELTO |
| [ADR-017](ADR-017-incremental-v0625-roadmap-adoption.md) | Adopción incremental de la hoja de ruta v0.6.25.x (Fases A→L); ~32 contratos v1 nuevos explícitamente diferidos | RESUELTO PARA BASELINE — alcance de contratos diferido |
| [ADR-018](ADR-018-platform-baseline-namespace-placement.md) | Ubicación de namespace para SPIRE y OpenBao (Fase B) — sin namespace nuevo, ambos en `argos-observability` | RESUELTO PARA BASELINE |
| [ADR-019](ADR-019-tool-manifest-v1-secure-lifecycle.md) | ToolManifest v1 (Fase G) — `side_effect_class`, `rate_limit`, DENY incondicional de IRREVERSIBLE/DESTRUCTIVE, Version Downgrade | RESUELTO PARA BASELINE |
| [ADR-020](ADR-020-safety-kernel-and-safety-envelope-v1.md) | Deterministic Safety Kernel + SafetyEnvelope v1, contrato 11 (Fase H) — producido, aún no consumido por OPA | RESUELTO PARA BASELINE — alcance explícitamente acotado |

Plantilla para ADR nuevos: `../templates/adr/ADR-template.md`. Proponer uno nuevo vía el issue template `architecture-decision.yaml`.
