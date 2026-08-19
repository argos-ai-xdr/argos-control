# As-built — ARGOS AI-Managed XDR (release 0.1.0-dev)

ARG-028 (S8, propuesta v0.6.25.4 §16.7): "As-built | Topología real,
namespaces, versiones, ADR/decisiones, interfaces, data flows, modos
REAL/EMULATED y desviaciones". Este documento cubre SOLO ese paquete —
de los 8 que exige ARG-028 (As-built, Release/restore, Operación XDR,
HITL/SOAR, Cyber-range, SOC handover, Gobierno, Formación), los otros 7
siguen honestamente `NOT EVALUATED` porque exigen infraestructura real
desplegada, un cyber-range operativo, o participación humana (auditoría,
formación) que no existe todavía — no se rellenan con contenido
aspiracional.

Es un documento **verificado a mano en esta fecha**, no autogenerado.
Cada afirmación es comprobable ejecutando el comando indicado o abriendo
el archivo citado — no es arquitectura de diseño (`architecture/` sí lo
es, y el propio documento maestro distingue explícitamente ambas cosas:
"los elementos recibidos se conservan como referencias de diseño, pero no
son arquitectura as-built ni fuente normativa").

**Fecha de verificación**: 2026-08-17. **Verificado por**: sesión de
desarrollo (no hay todavía un walkthrough con un revisor independiente —
ver "Validación receptor" pendiente al final).

## 1. Topología real

7 repositorios en la organización GitHub `argos-ai-xdr`, sin dependencias
de paquete entre sí (ADR-014) — solo `argos-contracts-scenarios` se
consume como checkout hermano en CI (`ARGOS_CONTRACTS_PATH`). Commits
exactos: [`release-manifest.yaml`](release-manifest.yaml).

| Repo | Rol | CI (GitHub Actions) |
| --- | --- | --- |
| `argos-control` | Gobierno, ADR, backlog, gates, registro OSS, releases | ✅ verde |
| `argos-platform` | IaC, cyber-range, namespaces, kill-switch/reset | ✅ verde |
| `argos-contracts-scenarios` | Envelope + 10 contratos v1, fixtures, escenario ARGOS-CYB-01 | ✅ verde |
| `argos-core` | Adapters, normalizer, correlator, risk-engine, recommendation | ✅ verde |
| `argos-cyber-tools` | Grafo RBAC/exposición, MCP gateway, executors, rollback | ✅ verde |
| `argos-validation` | Harness, evaluadores, suites, acceptance runner | ✅ verde |
| `argos-smartops` | API operador, approvals, handover | ✅ verde |

**RESUELTO 2026-08-19 (era una desviación activa)**: los 4 repos que
fallaban con "workflow was not found" al invocar el reusable workflow
de `argos-control` (0 jobs creados, no un fallo de test) tenían una
causa raíz distinta de la hipótesis `admin:org` que se manejaba antes —
confirmada con el conector GitHub del usuario: **un repo CALLER
público no puede consumir un reusable workflow de un repo CALLEE
privado** (`argos-control` era privado). Se pasó `argos-core`,
`argos-cyber-tools`, `argos-validation`, `argos-smartops` a privados;
`argos-control`/`argos-contracts-scenarios` a públicos (evita depender
de un PAT `CONTRACTS_CHECKOUT_TOKEN`/`CONTROL_CHECKOUT_TOKEN` nunca
configurado). Dos bugs reales encontrados y corregidos en el camino
(no reruns oportunistas): hash de integridad del catálogo no
reproducible entre Windows/Linux por CRLF/LF
(`argos-cyber-tools@1154fc7`), y `TRACE-01` degradando en silencio a
aviso en CI por falta de checkout hermano de `argos-control`
(`argos-validation@b55bc1a`/`3b412bf`, `argos-control@9af3f61`). CI
7/7 GREEN verificado run por run vía la API de GitHub, no solo el
`conclusion` agregado — ver
`argos-control/architecture/implementation-readiness.md` §1/§9/§13/§15
y `argos-validation/traceability.yaml` gate G0 (que sigue `PARTIAL`
por owners/calendario, no por CI).

## 2. Namespaces

10 namespaces declarados en `argos-platform/kubernetes/namespaces/*.yaml`,
todos con Pod Security Standard `restricted` (verificado por
`argos-platform/scripts/test.sh`): `argos-xdr`, `argos-cti`, `argos-ai`,
`argos-policy`, `argos-mcp`, `argos-soar`, `argos-smartops`,
`argos-observability`, `argos-evidence`, `argos-cyber-range`.

**Desviación**: estos manifests NO están desplegados contra ningún
cluster real todavía (ENV-QUAL-01, cualificación OSC/Gardener, sigue
`BLOCKED` — sin acceso a un cluster real, no hay ingeniería posible para
destrabarlo). `argos-platform/cyber-range/{reset,kill-switch}/*.sh`
operan sobre el namespace `argos-cyber-range` y están probados por
construcción (lógica bash real, revisada línea a línea), pero nunca
ejecutados contra un cluster real.

## 3. Versiones

**Ningún componente OSS tiene versión/digest fijado todavía.**
`helm/argos-services/Chart.yaml` declara `version: "TODO"` para NATS/
Keycloak/OpenSearch; `helm/argos-services/values.yaml` tiene los tres
`enabled: false`. `compatibility/oss-admission-registry.yaml` (OSS-QUAL-01)
documenta esto explícitamente por componente: identidad/digest
`PENDIENTE (ENV-QUAL-01)` en los 10 componentes registrados — la decisión
de ADMISIÓN (licencia, sostenibilidad, alternativa) sí está evaluada hoy,
el PIN de versión no.

Release del propio `argos-ai-xdr`: `0.1.0-dev`, `status: dev` (no
`candidate`, que exigiría `images`/`contracts`/`validation` completos por
schema, ver `releases/schema/release-manifest.schema.json`).

## 4. ADR / decisiones

16 ADR ratificadas en `adr/ADR-001..016-*.md`:

| ADR | Decisión |
| --- | --- |
| 001 | ARGOS Event Envelope v1 |
| 002 | NATS JetStream como bus de eventos MVP |
| 003 | Seguridad de MCP |
| 004 | Separación de identidades (usuarios, workloads, secretos) |
| 005 | OPA como Policy Decision Point |
| 006 | OpenSearch + Ceph RGW como almacén de evidencia |
| 007 | Fuentes CTI — MISP P0, IBM X-Force excluido |
| 008 | vLLM autogestionado con fallback determinista |
| 009 | Observabilidad soberana (OTel, Prometheus/Grafana, OpenSearch) |
| 010 | Toolchain P0 mínima |
| 011 | Nivel de autonomía del MVP — hasta L3 |
| 012 | Denominación del producto — AI-assisted XDR |
| 013 | Política de dependencias open source |
| 014 | Topología de repositorios — siete repositorios |
| 015 | CI/CD centralizado y despliegue GitOps |
| 016 | Política de almacenamiento de evidencia fuera de Git |

**Decisión pendiente de ADR formal, detectada esta sesión**: OSS-QUAL-01
introduce Kyverno (admisión/firma/attestations) sin baseline previo en
`compatibility/components.yaml`, que fija Gatekeeper para la capability
Policy — conviven o se sustituyen, decisión no tomada (ver
`compatibility/oss-admission-registry.yaml`, entrada Kyverno, campo
`gate_reason`).

## 5. Interfaces

Envelope (`envelope/v1/argos-envelope.schema.json`) + 10 contratos v1
cerrados (`argos-contracts-scenarios/schemas/`): `asset-snapshot`,
`vulnerability-finding`, `security-event`, `incident`, `recommendation`,
`policy-decision`, `approval`, `action-result`, `evidence-manifest`,
`soc-handover`. Ninguna capacidad nueva construida esta sesión (C-07
completo, drift, DMZ, checkpoints, acceptance runner) introdujo un
contrato v1 nuevo — el conjunto sigue siendo el mismo cerrado del
documento maestro §6.5; los artefactos internos sin contrato (grafo RBAC,
risk ranking, attack path, checkpoints CP00/01/04/05/12) se documentan
como tales, no se les inventa un contrato que no existe.

## 6. Data flows

Ver `architecture/data-flows/end-to-end-flow.md` (diseño) y, para el
flujo REALMENTE probado end-to-end,
`argos-contracts-scenarios/scenarios/ARGOS-CYB-01/expected/sample-run/` +
`argos-validation/harness/checkpoints.py`: 11 de los 14 checkpoints
CP00-CP13 validan hoy con un único `run_id` coherente encadenado
(`run-smoke-001`) — CP02→CP03→CP04→CP05→CP06→CP07→CP08→CP09→CP10→CP11→CP13.
CP00 (reset+atestación), CP01 (inyección) y CP12 (verificación
post-contención) exigen el cluster real de la sección 2, ausente.

## 7. Modos REAL/EMULATED

Ningún componente de este release afirma "REAL" cuando en realidad es
emulado — cada uno declara su modo explícitamente en el propio payload o
en el código, verificado archivo por archivo:

| Componente | Modo hoy | Evidencia |
| --- | --- | --- |
| Identidad del operador (`argos-smartops`) | EMULADO | `api/auth.py`: `get_current_operator` es un punto de extensión (`RuntimeError` si no se sobreescribe); sin Keycloak/OIDC real desplegado. `require_role` (autorización) sí es lógica real y probada. |
| SOC handover (`argos-smartops`) | `SOC_EMULATED` (constante explícita en el payload) | `api/handover.py`: `SOC_MODE = "SOC_EMULATED"`, sin endpoint SOC real autorizado todavía (ARG-022). |
| Telemetría DMZ (`argos-core`) | Ambos, declarado por flujo (`source_mode`) | `services/dmz_detector`: `REAL_CONNECTOR` \| `EMULATED`, nunca implícito; `InvalidSourceMode` si no es uno de los dos. |
| Recomendación (`argos-core`) | Determinista (fallback), no LLM | `services/recommendation.LangGraphEngine.generate` lanza `NotImplementedError` explícitamente — requiere vLLM real (DEP-06) y el grafo de ARG-019, ninguno desplegado. `DeterministicFallbackEngine` es el motor real en uso. |
| Contención/rollback (`argos-cyber-tools`) | Simulación en memoria | `executors/{kubernetes,scale_to_zero}.py`: `FakeClusterState`/`FakeReplicaState`, estado real en memoria (no un mock que finge), pero no un cluster real — documentado explícitamente en `runbooks/*.md`. |
| Autorización de tools (`argos-cyber-tools`) | REAL | `mcp_gateway.Gateway.authorize()` — política real evaluada contra bundles reales, ya integrado y probado en C-07 (attack path validation), no es un stub. |
| Cyber-range (`argos-platform`) | Sin desplegar | `kill-switch.sh`/`reset.sh` son código real y probado por construcción, nunca ejecutados contra un cluster real (sección 2). |

## 8. Desviaciones conocidas frente al documento maestro

Ninguna oculta — cada una tiene su propio issue/nota rastreable:

1. ~~**CI bloqueada en 4/7 repos**~~ **RESUELTO 2026-08-19** (sección 1)
   — CI 7/7 GREEN, dos bugs reales corregidos en el camino.
2. **ENV-QUAL-01 (cualificación OSC/Gardener)**: `BLOCKED`, sin vía de
   ingeniería posible sin acceso a un cluster real.
3. **CAP-01 (presupuesto de telemetría/sizing)**: sin datos del dataset
   preliminar S1-S2 todavía, no se fabrican números.
4. **ARG-025 (backup/restore OpenSearch/Ceph RGW)**: cero código en
   `argos-platform` — Ceph RGW no tiene ni siquiera decidido si se
   despliega Rook-Ceph o un servicio S3 gestionado de OSC (DEP-02).
5. **ARG-023 (CP00/CP01/CP12)**: sin cluster real, no capturables (ver
   sección 6).
6. **Kyverno sin ADR de convivencia/sustitución con Gatekeeper** (sección
   4).
7. **Governed Agentic RAG, Deep Assurance, Continuous Trust, Sovereign
   Safety Kernel/Trust Anchor, Semantic Trust Fabric**: el propio
   documento maestro v0.6.25.4 los declara "SPECIFIED / PREPARED - NOT
   EXECUTED" — correctamente no implementados, no es un gap de este
   equipo.
8. **G7 (Acceptance Gate) permanece BLOCKED**: depende de G6 (arriba) y
   de las 7 secciones de ARG-028 no cubiertas por este documento.

## Validación receptor (pendiente)

El paquete "As-built" exige, per ARG-028: "Walkthrough + diff contra
objetivo" por un revisor DISTINTO de quien lo construyó. Ese walkthrough
no ha ocurrido todavía — este documento es la base verificable sobre la
que se haría, no un sustituto de esa revisión independiente.
