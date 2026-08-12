# Zonas de confianza y conectividad

Tabla autoritativa (documento maestro v0.5, 6.2.2). Cualquier conexión no listada aquí debe producir `DENY` por defecto (default-deny).

| Origen | Destino permitido | Protocolo | Control |
| --- | --- | --- | --- |
| Agents/collectors | normalizer/ingest | OTLP/HTTPS o agente nativo | mTLS, identity, rate limit y tamaño máximo |
| normalizer/correlator | NATS JetStream | TLS | Subjects allowlist, durable consumer y retención definida |
| LangGraph | MCP gateway/OPA/vLLM | MCP + HTTPS | Audience exacta, scopes y sin token passthrough |
| MCP gateway | Tools read-only/dry-run | HTTPS/K8s API | Schema, target allowlist, timeout y egress deny |
| Shuffle executor | Cilium/K8s cyber-range | K8s API | `approval_id`, `plan_hash`, RBAC mínimo e idempotencia |
| SmartOps | approval API/evidence | HTTPS | OIDC, MFA del aprobador, ABAC y redacción |
| SOC adapter | SOC emulado/externo | STIX/TAXII/JSON | TLP, campos permitidos, firma, ACK y reintento |

## Cyber-range (zona de máximo aislamiento)

Namespace `argos-cyber-range` aislado en Kubernetes; egress denegado salvo repositorios y endpoints sinkhole aprobados. El namespace, las identidades, los endpoints y las acciones permitidas forman una **allowlist cerrada**: todo destino no incluido debe producir `DENY`. Ver ARG-003 (base), ARG-011 (grafo de exposición), ARG-013 (validación de attack path).

## Regla general

Ningún componente del plano P3 (IA/política) tiene credenciales directas de enforcement. Ningún componente del plano P4 (SOAR/enforcement) ejecuta sin `approval_id` válido emitido por el plano P5 (Operación). Ver ADR-003, ADR-005, ADR-011.
