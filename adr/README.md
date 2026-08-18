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
| [ADR-051](ADR-051-incremental-v0625-roadmap-adoption.md) | Adopción incremental de la hoja de ruta v0.6.25.x (Fases A→L); ~32 contratos v1 nuevos explícitamente diferidos | RESUELTO PARA BASELINE — alcance de contratos diferido |
| [ADR-052](ADR-052-platform-baseline-namespace-placement.md) | Ubicación de namespace para SPIRE y OpenBao (Fase B) — sin namespace nuevo, ambos en `argos-observability` | RESUELTO PARA BASELINE |
| [ADR-053](ADR-053-tool-manifest-v1-secure-lifecycle.md) | ToolManifest v1 (Fase G) — `side_effect_class`, `rate_limit`, DENY incondicional de IRREVERSIBLE/DESTRUCTIVE, Version Downgrade | RESUELTO PARA BASELINE |
| [ADR-054](ADR-054-safety-kernel-and-safety-envelope-v1.md) | Deterministic Safety Kernel + SafetyEnvelope v1, contrato 11 (Fase H) — producido, aún no consumido por OPA | RESUELTO PARA BASELINE — alcance explícitamente acotado |
| [ADR-055](ADR-055-independent-verifier.md) | Independent Verification Barrier (Fase H) — re-confirma el SafetyEnvelope con hechos frescos; INCONCLUSIVE/REJECTED → ZERO EXECUTE | RESUELTO PARA BASELINE — alcance explícitamente acotado |
| [ADR-056](ADR-056-increase-monitoring-executor.md) | Executor real para `increase_monitoring` (Fase I) — backend Wazuh, cierra el último hueco de las 3 acciones execute del catálogo | RESUELTO PARA BASELINE |
| [ADR-057](ADR-057-evidence-root-and-local-transparency-log.md) | EvidenceRoot determinista + Transparency Log local con hash-chain (Fase J) — sin Merkle, sin firma real, sin contrato v1 nuevo | RESUELTO PARA BASELINE — alcance explícitamente acotado |
| [ADR-058](ADR-058-semantic-cyber-graph.md) | Semantic Cyber Graph (Fase K) — `CyberSemanticEntity`/`SemanticRelation` deterministas, sin generación por LLM | RESUELTO PARA BASELINE |
| [ADR-059](ADR-059-temporal-knowledge.md) | Temporal Knowledge (Fase K) — `query_at(T)`, `future_information_leakage=0` | RESUELTO PARA BASELINE |
| [ADR-060](ADR-060-mission-context-and-blast-radius.md) | MissionContext + blast radius técnico/operacional/misión (Fase K) — UNKNOWN nunca es impacto cero | RESUELTO PARA BASELINE |
| [ADR-061](ADR-061-semantic-conflict-and-authority-precedence.md) | SemanticConflict + Authority precedence (Fase K) — extiende `asset_reconciler`, nunca elige arbitrariamente | RESUELTO PARA BASELINE |
| [ADR-062](ADR-062-safety-kernel-mission-context-integration.md) | Integración de MissionContext en Safety Kernel (Fase K) — mission_impact_bounded real, MissionContext nunca decide autorización | RESUELTO PARA BASELINE — alcance explícitamente acotado |
| [ADR-063](ADR-063-mission-decision-evidence-integration.md) | Integración de evidencia de decisiones de misión con Fase J (Fase K) — reutiliza evidence_root/evidence_writer, sin mecanismo paralelo | RESUELTO PARA BASELINE |
| [ADR-064](ADR-064-security-domain-and-tenant-isolation.md) | SecurityDomain y aislamiento tenant/dominio (Fase L) — deny-by-default real, sin inferir permiso de la ausencia de prohibición | RESUELTO PARA BASELINE |
| [ADR-065](ADR-065-federated-artifact-and-federation-decision.md) | FederatedArtifact + evaluación local de confianza (Fase L) — "la federación transporta información, nunca autoridad"; ACCEPT != ACTIVE | RESUELTO PARA BASELINE — alcance explícitamente acotado |
| [ADR-066](ADR-066-cross-domain-transfer-ifc-sanitization.md) | CrossDomainTransfer + IFC + sanitización determinista (Fase L) — ningún LLM desclasifica de forma autoritativa | RESUELTO PARA BASELINE |
| [ADR-067](ADR-067-federation-transport-and-evidence-integration.md) | Transporte de prueba (TEST_LOCAL) + integración de evidencia de Federation con Fase J (Fase L) — REAL_TRANSPORT=BLOCKED_EXTERNAL | RESUELTO PARA BASELINE — alcance explícitamente acotado |
| [ADR-068](ADR-068-chaos-engineering-resilience-validation.md) | Chaos Engineering & Chaos Monkey Validation Profile (Fase M, posterior a A→L) — Chaos Mesh P0 sobre Netflix Chaos Monkey (evita dependencia de Spinnaker), plano de validación nunca productivo, quality gates `CH-*` | RESUELTO PARA BASELINE — alcance explícitamente acotado |
| [ADR-069](ADR-069-kafka-detection-engineering-loop.md) | Kafka Event Streaming Plane & Autonomous Detection Engineering Loop (Fase N) — Kafka paralelo a NATS JetStream (desviación explícita de `ADR-002`, justificada), `AI_DIRECT_RULE_DEPLOYMENT=DENY`, investigación global L0-L5, compilador determinista de reglas Wazuh, backtesting obligatorio, gating por `CH-07` | RESUELTO PARA BASELINE — alcance explícitamente acotado |
| [ADR-070](ADR-070-intelligent-detection-loop-reconciliation.md) | Reconciliación del Intelligent Detection Loop (Fase N, extiende `ADR-069`) — Statistical Detector separado del Global Investigator, sidecar Wazuh solo `CANDIDATE`, protección anti-recursión `DE-19`, `Classification v1`/`DetectionTombstone v1`/`DetectionModelManifest v1`/`WazuhDecoderSpec v1`, gates `DE-19..30`, laboratorio `IDLAB-01..08` | RESUELTO PARA BASELINE — alcance explícitamente acotado |

Plantilla para ADR nuevos: `../templates/adr/ADR-template.md`. Proponer uno nuevo vía el issue template `architecture-decision.yaml`.
