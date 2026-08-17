# Topología lógica — seis planos

La baseline ejecutable (documento maestro v0.5, 6.2) se organiza en seis planos con responsabilidades y límites de confianza explícitos. Todos los namespaces aplican Pod Security Standards, `NetworkPolicy` default-deny, cuotas, service accounts dedicadas, imágenes firmadas y salida de red cerrada salvo allowlists versionadas.

| Plano | Namespaces / componentes P0 | Responsabilidad y límite | Repositorio(s) |
| --- | --- | --- | --- |
| P1 Edge/telemetría | `kube-system` + agents: Falco, Hubble, Wazuh Agent, Kubernetes Audit | Capturar hechos cerca de la fuente; sin decisión ni ejecución de remediación. | `argos-platform` (despliegue) |
| P2 XDR/contexto | `argos-xdr`: Wazuh/OpenSearch, normalizer, correlator; `argos-cti`: MISP | Normalizar, correlacionar y enriquecer con snapshots; conserva payload nativo por referencia. | `argos-core` (lógica), `argos-platform` (namespaces) |
| P3 IA/política | `argos-ai`: LangGraph API, vLLM; `argos-policy`: OPA; `argos-mcp`: tool gateway | Proponer opciones y evaluar política. Sin credenciales directas de enforcement. | `argos-core` (recommendation), `argos-cyber-tools` (mcp-gateway, políticas OPA) |
| P4 SOAR/enforcement | `argos-soar`: Shuffle; `argos-cyber-range`: ejecutores Cilium/K8s | Dry-run y ejecución reversible solo con `approval_id` válido, target autorizado e `idempotency_key`. | `argos-cyber-tools` |
| P5 Operación | `argos-smartops`: UI/API; `argos-soc-adapter` | Presentar contexto inmutable, aprobar/rechazar, monitorizar y exportar handover filtrado. | `argos-smartops`, `argos-core` (soc-adapter) |
| P6 Evidencia/plataforma | `argos-observability`: OTel/Prometheus/Grafana, SPIRE Server, OpenBao; `argos-evidence`: OpenSearch + Ceph RGW | Trazas, métricas, manifiestos, hashes, retención y reconstrucción de cada run. | `argos-platform` |

## Principios (documento maestro v0.5, 6.1)

* **Contract-first**: productores y consumidores se integran mediante JSON Schema, OpenAPI/AsyncAPI y eventos versionados; ningún componente comparte tablas internas con otro dominio.
* **Zero trust entre planos**: identidad de workload, mTLS, default-deny, scopes mínimos y autorización por acción, target y entorno.
* **No-RAG/Cyber separado de RAG/Chat**: ARGOS-CYB-01 usa hechos estructurados y evidencias; Milvus y la asistencia documental no participan en los gates críticos de contención.
* **Human-In-The-Loop obligatorio**: el MVP permite observar, recomendar, simular y ejecutar una acción reversible aprobada; no existe remediación autónoma de alto impacto (ver ADR-011).
* **Reproducibilidad offline**: imágenes, modelos, políticas, datasets, CTI, schemas y runbooks quedan fijados por versión, digest y hash antes de aceptación.
* **Open source y portabilidad**: cada capacidad P0 tiene alternativa autogestionable y formato de salida abierto (ver ADR-013).

Namespaces mínimos a crear en `argos-platform`: `argos-xdr`, `argos-cti`, `argos-ai`, `argos-policy`, `argos-mcp`, `argos-soar`, `argos-smartops`, `argos-observability`, `argos-evidence`, `argos-cyber-range`. Este conjunto es cerrado (validado en `argos-platform/scripts/test.sh`); SPIRE/OpenBao no amplían la lista — se alojan en `argos-observability` por ubicación, no porque sean responsabilidad de P6 (sirven a los seis planos por igual, ver ADR-052).
