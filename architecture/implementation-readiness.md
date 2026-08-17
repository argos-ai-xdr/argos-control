# Global A→L Evidence & Readiness Reconciliation

**Fecha de generación**: 2026-08-17. **Alcance**: Fases A→L (`ADR-051..067`).
**FEATURE_FREEZE_A_L = TRUE** durante esta reconciliación — ningún cambio
de este documento ni de los commits que lo acompañan añade arquitectura,
capacidad de IA, feature de federación, motor semántico nuevo,
comportamiento de orquestación nuevo, acción de enforcement nueva ni
infraestructura especulativa. Los únicos cambios de código permitidos y
realizados son: (1) corrección de `CLAIM-009`/`CLAIM-010` obsoletos en
`assurance/argos-assurance.yaml` (documentación), (2) este documento y
`traceability/implementation-readiness.yaml` (nuevos, documentación),
(3) actualización del veredicto ejecutivo obsoleto de
`architecture/v0.6.25-gap-matrix.md` (documentación).

Este documento **no sustituye** `architecture/v0.6.25-gap-matrix.md`
(huecos por sección del prompt v0.6.25.x) ni
`argos-validation/traceability.yaml` (gate→story→contrato→test→métrica
para ARG-001..028/G0-G7). Los complementa: cubre el tramo que ninguno de
los dos cubre — `ADR-053..067`, que nació explícitamente fuera del
backlog ARG-001..028 (ADR-051).

---

## 1. Executive Readiness Summary

**Dos preguntas distintas, dos respuestas distintas — no se mezclan (regla §17):**

```
A_L_IMPLEMENTATION_READINESS = GREEN
G0_ACTIVATION_READINESS      = BLOCKED
```

El roadmap A→L (Safety Kernel, Independent Verifier, Evidence/Transparency
Log, Semantic Cyber Graph, Mission Context, Federation) está **construido,
probado localmente y honestamente acotado**: 683 tests reales entre los 4
repos Python (`argos-core` 376, `argos-cyber-tools` 99, `argos-validation`
138, `argos-smartops` 70), más validación de schema/fixtures en
`argos-contracts-scenarios` y `argos-platform`, todo en verde, `ruff`/
`mypy` limpios, working tree limpio en los 7 repos al commit de este
documento (§14).

**G0** (el gate real de "owners, accesos, calendario, P0 y DoR
aprobados", `governance/gates/gates.md`) está **BLOCKED**, y no por un
hueco técnico de A→L: (a) `argos-validation/traceability.yaml` ya lo
declara `PARTIAL` por CI de GitHub Actions no verde en 4/7 repos
("workflow was not found"), pendiente de una acción del usuario fuera de
este repositorio; (b) el hito M0 del calendario real
(`governance/gates/gates.md`) es el **14 sep 2026** — este documento se
genera el 2026-08-17, **antes** de esa fecha; (c) los "owners" declarados
en cada `repository.yaml` son roles (`poa-architecture`,
`delivery-lead`), no personas nombradas con una decisión de dotación
real. Ninguna cantidad de código A→L cierra G0 — G0 no es una brecha de
implementación.

**Hallazgo más importante de esta reconciliación** (§5, Security
Invariant Matrix): `SafetyEnvelope`/Independent Verifier son reales y
probados **de forma aislada**, pero `argos-cyber-tools/mcp_gateway/
__init__.py::Gateway.authorize()` — el gate que HOY gobierna la
ejecución real — no importa ni consulta `SafetyEnvelope` ni
`independent_verifier` en absoluto (cero referencias, verificado por
grep). El camino de ejecución real sigue gobernado únicamicamente por
`target_allowlist` + `Approval` (`CLAIM-001`/`CLAIM-006`, SUPPORTED/
PARTIALLY_SUPPORTED). Esto ya estaba declarado honestamente en
`architecture/v0.6.25-gap-matrix.md` ("PRODUCIDO, no consumido todavía
por OPA") pero esta reconciliación lo eleva a hallazgo `CRITICAL`
explícito porque afecta a un claim de seguridad, no solo a una nota de
alcance.

**Hallazgo de trazabilidad** (§7-8): `ADR-053` a `ADR-067` (15 ADR,
Fases G[parcial]/H/I/J/K/K.1/L) no tienen ninguna historia
`ARG-001..028` asociada — no es exclusivo de Federation, es el patrón de
todo el tramo post-`ADR-051`, adoptado deliberadamente así (ADR-051,
Consecuencia). Se clasifica como `UNMAPPED_IMPLEMENTATION_CANDIDATE`
(§8) — no se resuelve aquí, queda pendiente de aprobación del usuario.

---

## 2. A→L Phase Matrix

| Fase | Capacidad | ADR | Estado declarado | Verificado en esta reconciliación |
| --- | --- | --- | --- | --- |
| A-F | MVP (C-06/C-07/C-08+HITL), gobierno documental | ADR-001..016, 051 | Real (backlog ARG-001..028) | Confirmado: 99+138+70 tests verdes en cyber-tools/validation/smartops |
| G | ToolManifest v1 (`side_effect_class`, DENY incondicional) | ADR-053 | `IMPLEMENTED_LOCALLY_AND_TESTED` | Confirmado |
| H | Safety Kernel + SafetyEnvelope v1 | ADR-054 | `IMPLEMENTED_LOCALLY_AND_TESTED` (producido, no consumido por gateway real) | Confirmado — **ver hallazgo CRITICAL §5** |
| H | Independent Verifier | ADR-055 | `IMPLEMENTED_LOCALLY_AND_TESTED` | Confirmado (mismo hallazgo: no wired al gateway) |
| I | Executor `increase_monitoring` (Wazuh) | ADR-056 | `IMPLEMENTED_LOCALLY_AND_TESTED`; `REAL_SHUFFLE_INTEGRATION=BLOCKED_EXTERNAL` | Confirmado |
| J | EvidenceRoot + Transparency Log local | ADR-057 | `IMPLEMENTED_LOCALLY_AND_TESTED`; firma criptográfica/WORM físico `BLOCKED_EXTERNAL` | Confirmado |
| K | Semantic Graph / Temporal Knowledge / Mission Context / Semantic Conflict | ADR-058..063 | `IMPLEMENTED_LOCALLY_AND_TESTED`; `MISSION_SOURCE_INTEGRATION=CONTRACTUAL/EMULATED` | Confirmado |
| K.1 | Independent Verifier consciente de misión | ADR-055 (actualización), ADR-062 (actualización) | `IMPLEMENTED_LOCALLY_AND_TESTED` | Confirmado |
| L | Federation Core / Cross-Domain Core / Federation Policy Engine | ADR-064..067 | `IMPLEMENTED_LOCALLY_AND_TESTED`; `REAL_MULTI_SITE_FEDERATION`/`EXTERNAL_FEDERATION_IDENTITY`/`EXTERNAL_TRUST_ESTABLISHMENT`/`REAL_CROSS_DOMAIN_GATEWAY`/`REAL_TRANSPORT` = `BLOCKED_EXTERNAL` | Confirmado |

Ninguna claim se elevó de estado durante esta verificación — todas las
fases ya declaraban su propio alcance con honestidad al cierre de cada
fase. Esta reconciliación **confirma por inspección fresca** (pytest/
ruff/mypy repo-wide, commit HEAD real, grep estructural) en vez de dar
por buena la autodeclaración de cada fase.

---

## 3. Maturity vocabulary (usado en este documento y en `traceability/implementation-readiness.yaml`)

`SPECIFIED` · `SCAFFOLDED` · `IMPLEMENTED_LOCALLY` · `TESTED_LOCALLY` ·
`IMPLEMENTED_LOCALLY_AND_TESTED` · `VALIDATED_IN_LAB` · `DEMONSTRATED` ·
`VALIDATED_IN_TARGET` · `ACTIVE` — y estados limitantes: `PARTIAL` ·
`CONTRACTUAL` · `EMULATED` · `BLOCKED_INTERNAL` · `BLOCKED_EXTERNAL` ·
`NOT_IMPLEMENTED` · `NOT_EVALUATED` · `NOT_APPLICABLE`.

Niveles de evidencia E0-E8 (§4 del prompt de reconciliación): este
repositorio no tiene una taxonomía canónica previa más específica, así
que se adopta la del prompt tal cual (ver
`traceability/implementation-readiness.yaml`, campo `evidence_level`).
Todo lo construido en A→L alcanza como máximo **E4** (integración local +
prueba adversarial) — nada alcanza E5+ salvo `CAP-I-01` (E5, adaptador
real Wazuh) y `CAP-J-01` (E5, hash real aunque sin object-lock físico).
**Nada alcanza E6-E8** (no hay entorno desplegado, no hay validación en
infraestructura objetivo, no hay reproducción independiente/sign-off
externo).

---

## 4. ADR→ARG→Code→Test→Evidence Matrix

Ver `traceability/implementation-readiness.yaml` (machine-readable,
19 capacidades, `ADR-051` a `ADR-067`). Resumen:

| ADR | Fase | ARG | Código | Tests | Evidencia runtime | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| ADR-051 | A | — (decisión de secuenciación) | N/A | N/A | N/A | RESUELTO |
| ADR-052 | B | ARG-002, ARG-003 | `argos-platform` | `scripts/test.sh` | validate/test OK | RESUELTO |
| ADR-053 | G | *ninguna* | `tool_catalog/` | `tests/authorization` | 99 tests cyber-tools | `IMPLEMENTED_LOCALLY_AND_TESTED` |
| ADR-054 | H | *ninguna* | `services/safety_kernel` | `test_safety_kernel.py` | 376 tests core | `IMPLEMENTED_LOCALLY_AND_TESTED`, no wired a gateway (§5) |
| ADR-055 | H/K.1 | *ninguna* | `services/independent_verifier` | `test_independent_verifier.py` | ídem | ídem |
| ADR-056 | I | ARG-021 | `executors/` | `tests/idempotency`,`tests/rollback` | 99 tests cyber-tools | `IMPLEMENTED_LOCALLY_AND_TESTED` |
| ADR-057 | J | *ninguna* | `services/evidence_{writer,root}` | `test_evidence_root.py` et al. | 376 tests core | `IMPLEMENTED_LOCALLY_AND_TESTED` |
| ADR-058..063 | K | *ninguna* | `services/{semantic_graph,temporal_knowledge,mission_context,semantic_conflict}` | 5 archivos test | 376 tests core | `IMPLEMENTED_LOCALLY_AND_TESTED` |
| ADR-064..067 | L | *ninguna* | `services/federation/*` | 12 archivos test | 376 tests core | `IMPLEMENTED_LOCALLY_AND_TESTED` |

**Orphan detection (§6/§9 del prompt de reconciliación)**:

* `ORPHAN_ADR` (ADR sin implementación): **0** — cada ADR-051..067 tiene
  código real correspondiente, verificado.
* `ADR con implementación pero sin test`: **0** — cada módulo nuevo
  tiene su archivo de test correspondiente, verificado por listado de
  `tests/`.
* `ADR con tests pero sin evidencia runtime`: **0** para Fases H-L
  (todas producen `EvidenceManifest`/`EvidenceRoot` real cuando aplica,
  o están fuera del alcance de evidencia por diseño — p. ej. ADR-053).
* `ADR sin ARG`: **15** (`ADR-053..067`) — ver `UNMAPPED_IMPLEMENTATION`
  §8.
* `Semántica ADR duplicada`: **0** detectada.
* `Colisión de numeración`: **0** — registro inspeccionado antes de
  cada asignación desde `ADR-051` en adelante (verificado esta sesión en
  cada fase; `ADR-067` es el techo real al generar este documento).
* `ADR implementado más allá de la madurez declarada`: **0** — ninguna
  fase reclama más de `IMPLEMENTED_LOCALLY_AND_TESTED`.

### 4.1 Federation/ADR-053..067 traceability decision (§8)

Clasificación inicial: **`UNMAPPED_IMPLEMENTATION_CANDIDATE`** para todo
el rango `ADR-053..067` (Federation, `ADR-064..067`, es el caso más
visible pero no el único — ver §4).

Evaluación de las tres opciones:

* **A. `EXISTING_ARG_VALID_MAPPING`** — descartada. Se revisaron
  `ARG-001..028` (`project/backlog/backlog.yaml`) buscando un alcance
  original que genuinamente incluyera Federation/Safety Kernel/Evidence/
  Semantic Graph. El más cercano por texto es `ARG-020` ("OPA policy
  gate, approval API, TTL, firma y anti-replay") — pero su alcance
  original es el gate de aprobación, no aislamiento tenant/dominio ni
  transporte de artefactos federados. Forzar el mapeo sería estirar la
  redacción retroactivamente, exactamente lo que el prompt de
  reconciliación prohíbe.
* **B. `CROSS_CUTTING_IMPLEMENTATION_WITHOUT_NEW_ARG`** — **válida hoy**,
  con respaldo textual real: `ADR-051` (Consecuencia) ya es una decisión
  de gobernanza ratificada (Product Owner/Arquitectura, confirmación
  explícita del usuario) que autoriza construir el roadmap A→L fuera del
  backlog `ARG-001..028`, "cada fase debe justificar su propia historia
  cuando se aborde, no antes". La trazabilidad, además, ya no está
  incompleta: `traceability/implementation-readiness.yaml` +
  `architecture/implementation-readiness.md` cierran exactamente el
  eslabón ADR→código→test→evidencia que antes solo faltaba por un
  número de ARG.
* **C. `NEW_ARG_REQUIRED`** — **recomendado como siguiente paso**, no
  porque B sea inválida arquitectónicamente, sino porque B resuelve la
  trazabilidad de diseño y C resuelve algo distinto: visibilidad de
  backlog/capacidad para planificación (story points, sprint,
  dependencias) — algo que ADR-051 deliberadamente no intentó sustituir.

**Propuesta de `ARG-029` (NO creada — solo reportada, a la espera de
aprobación explícita)**:

| Campo | Valor propuesto |
| --- | --- |
| ID recomendado | `ARG-029` |
| Título | "Federation Core / Cross-Domain Core / Federation Policy Engine (Fase L)" |
| Alcance | `SecurityDomain`, `FederatedArtifact`, `FederationDecision`, `CrossDomainTransfer`, IFC, sanitización determinista, anti-replay/revocación — tal como está implementado en `argos-core/services/federation` |
| Fase | L |
| Prioridad | P1 (no bloquea ningún AC01-14 ni gate G0-G7 existente) |
| Dependencias | ARG-011..014 (grafo RBAC/red, reutilizado no duplicado), Fase K (semantic_conflict, reutilizado) |
| Paths implementados | `argos-core/services/federation/*` (§4, `CAP-L-01..05`) |
| Evidencia existente | 69 tests (`CAP-L-01..05`, `traceability/implementation-readiness.yaml`), `ADR-064..067` |
| Justificación retroactiva | Documentar trabajo ya construido y probado, no planificar trabajo futuro — mismo criterio que `ARG-027`/`ARG-028` cuando se escribieron sobre capacidad ya existente |

Podría repetirse el mismo ejercicio para `ADR-053..063` (`ARG-030+`) si
el usuario decide que B ya no es suficiente para todo el tramo, no solo
para Federation. **No se crea ningún ARG en esta reconciliación.**

---

## 5. Security Invariant Matrix

| Invariante | Test path | Resultado | Estado |
| --- | --- | --- | --- |
| AI no puede autorizar | `assurance/argos-assurance.yaml::CLAIM-005` (verificación por grep de imports, no test automatizado) | Sin import de `recommendation`→`executors` | `PARTIALLY_SUPPORTED` (sin test que FALLE si se rompe en el futuro) |
| Safety Kernel no puede aprobar | Estructural: `safety_kernel` no produce `Approval`, no importa `ApprovalStore` | Confirmado por diseño | `SUPPORTED` (estructural) |
| Independent Verifier no puede aprobar | Estructural: `independent_verifier` no produce `Approval` | Confirmado por diseño | `SUPPORTED` (estructural) |
| OPA no proporciona Approval humana | `policy_adapter` vs `ApprovalStore` son módulos distintos, sin solapamiento | Confirmado | `SUPPORTED` (estructural) |
| Sin Approval válida → no execute crítico | `argos-cyber-tools/tests/authorization/test_gateway.py` | PASS | `SUPPORTED` — **este es el gate real hoy** |
| Approval caducada → no execute | `argos-cyber-tools/tests/anti-replay/test_approval_anti_replay.py` | PASS | `SUPPORTED` |
| `plan_hash` cambiado → no execute | `test_approval_anti_replay.py` (signature_ref vs plan_hash actual) | PASS | `SUPPORTED` |
| **Violación de `SafetyEnvelope` → no execute** | *(ninguno — sin integración)* | **`Gateway.authorize()` no referencia `SafetyEnvelope` (grep: 0 resultados)** | **`NOT_SUPPORTED` a nivel de integración — CRITICAL** |
| **Verifier `REJECTED` → no execute** | *(ninguno — sin integración)* | **`Gateway.authorize()` no referencia `independent_verifier`/`VerificationResult` (grep: 0 resultados)** | **`NOT_SUPPORTED` a nivel de integración — CRITICAL** |
| Verifier `INCONCLUSIVE` → no execute | Unit: `test_independent_verifier.py` (aislado) | PASS en aislamiento | `PARTIALLY_SUPPORTED` (mismo hueco de integración) |
| Violación CRITICAL de misión → no execute | Unit: `test_mission_context.py`, `test_safety_kernel.py` (aislado) | PASS en aislamiento | `PARTIALLY_SUPPORTED` (mismo hueco de integración) |
| `UNKNOWN` crítico de misión nunca → `VERIFIED` | `test_k1_mission_verifier_vertical_slice.py` | PASS | `SUPPORTED` (dentro del módulo) |
| `FederatedArtifact` → nunca autoridad de ejecución local | `test_federation_safety_vertical_slice.py` | PASS — estructural + funcional | `SUPPORTED` |
| Cross-domain transfer → decisión de política explícita | `test_cross_domain_transfer.py`, `test_federation_ifc.py` | PASS | `SUPPORTED` |
| Desclasificación automática = 0 | `test_federation_ifc.py::test_classification_downgrade_request_requires_approval_never_auto_allowed` | PASS | `SUPPORTED` |
| Promoción automática a `ACTIVE` remoto = 0 | `test_federation_decision.py::test_accept_never_implies_active` | PASS | `SUPPORTED` |
| Mutación de evidencia → falla verificación | `test_evidence_j_invariants.py`, `test_transparency_log.py` (mutación detectada) | PASS | `SUPPORTED` |
| Mutación de la cadena de transparencia → falla verificación | `test_transparency_log.py::verify_chain` | PASS | `SUPPORTED` |
| Artefacto federado revocado → no aceptado | `test_federation_decision.py::test_revoked_artifact_is_rejected`, adversarial | PASS | `SUPPORTED` |
| Fuga cross-tenant = 0 | `test_federation_adversarial.py::test_cross_tenant_confusion_yields_zero_implicit_access` | PASS | `SUPPORTED` |

**Bloqueante identificado (`CRITICAL`, no `MAJOR`)**: los dos invariantes
en negrita significan que, en el estado real del sistema HOY, un
`ActionRequest` con `dry_run=false` puede alcanzar `execute` habiendo
pasado por `target_allowlist`+`Approval` **sin haber pasado nunca por
Safety Kernel ni Independent Verifier** — porque nada en el gateway real
los invoca. Esto no invalida las Fases H/K.1 (los módulos son correctos
y probados en su propio contrato de entrada/salida), pero sí invalida
cualquier afirmación de que "ARGOS hoy no ejecuta sin pasar el Safety
Kernel" a nivel de sistema. Ver remediación R0 en §13.

---

## 6. Contract Implementation Matrix

11 contratos v1 activos en `argos-contracts-scenarios/schemas/`
(`asset-snapshot, vulnerability-finding, security-event, incident,
recommendation, policy-decision, approval, action-result,
evidence-manifest, soc-handover, safety-envelope`). Los 10 primeros son
el **conjunto cerrado** (documento maestro §6.5); `safety-envelope` es
la única excepción ratificada (ADR-054, "contrato 11").

| Contrato | Schema | Productor | Consumidor | Tests +/- | Uso runtime real | Evidencia |
| --- | --- | --- | --- | --- | --- | --- |
| asset-snapshot | ✓ | `asset_reconciler` | `risk_engine`, `semantic_graph` | ✓/✓ | Real | fixtures + tests |
| vulnerability-finding | ✓ | `vulnerability_adapter` | `risk_engine` | ✓/✓ | Real | fixtures + tests |
| security-event | ✓ | conectores Wazuh/Falco/Hubble | `normalizer` | ✓/✓ | Real | fixtures + tests |
| incident | ✓ | `correlator` | `recommendation`, `safety_kernel` | ✓/✓ | Real | fixtures + tests |
| recommendation | ✓ | `recommendation` | `safety_kernel`, `policy_adapter` | ✓/✓ | Real | fixtures + tests |
| policy-decision | ✓ | `policy_adapter` | `mcp_gateway` | ✓/✓ | Real (pero `InMemoryPolicyDecisionPoint`, no OPA servidor) | fixtures + tests |
| approval | ✓ | `smartops/api/approvals.py` | `mcp_gateway` | ✓/✓ | Real | fixtures + tests |
| action-result | ✓ | `executors` | `evidence_writer` | ✓/✓ | Real | fixtures + tests |
| evidence-manifest | ✓ | `evidence_writer` | `evidence_root` | ✓/✓ | Real | fixtures + tests |
| soc-handover | ✓ | `soc_adapter` | `smartops` | ✓/✓ | Real | fixtures + tests |
| safety-envelope | ✓ | `safety_kernel` | **nadie todavía** (ver §5) | ✓/✓ (unit) | **Solo local, sin consumidor real** | `test_safety_kernel.py`, sin fixture end-to-end en `mcp_gateway` |

**Contratos schema-only**: ninguno — los 11 tienen productor y
consumidor real con tests positivos y negativos, salvo `safety-envelope`
cuyo "consumidor" (`Gateway.authorize`) no existe todavía (§5).

**Sin contrato v1 nuevo para Fases K/L** (decisión deliberada,
documentada en cada ADR — `SemanticEntity`/`MissionContext`/
`FederatedArtifact`/`FederationDecision`/`CrossDomainTransfer` viven
como estructuras internas de `argos-core`, ningún otro repo los
consume todavía, mismo criterio que `EvidenceRoot`/`VerificationResult`
en su momento).

---

## 7. Integration Truth Matrix (fuentes reales vs. emuladas)

| Integración | Adaptador/código | Credenciales | Endpoint | Datos reales | Fixture | Probado | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Wazuh | ✓ (`connectors/wazuh`) | — | — | — | ✓ | ✓ | `FIXTURE` |
| Falco | ✓ | — | — | — | ✓ | ✓ | `FIXTURE` |
| Hubble/Cilium | ✓ | — | — | — | ✓ | ✓ | `FIXTURE` |
| Kubernetes | ✓ (executors) | — | — | — | `FakeClusterState` | ✓ | `EMULATED` |
| CMAM | ✓ | — | — | — | ✓ | ✓ | `FIXTURE` |
| NetBox | ✓ | — | — | — | ✓ | ✓ | `FIXTURE` |
| MISP | ✓ | — | — | — | ✓ | ✓ | `FIXTURE` |
| Trivy | ✓ | — | — | — | ✓ | ✓ | `FIXTURE` |
| OpenVAS | ✓ | — | — | — | ✓ | ✓ | `FIXTURE` |
| Shuffle | Interfaz solo | ✗ | ✗ | ✗ | ✗ | ✗ | `BLOCKED_EXTERNAL` |
| Keycloak | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | `NOT_CONFIGURED` |
| SPIRE | ✗ (namespace reservado, `ADR-052`) | ✗ | ✗ | ✗ | ✗ | ✗ | `NOT_CONFIGURED` |
| OpenBao | ✗ (namespace reservado) | ✗ | ✗ | ✗ | ✗ | ✗ | `NOT_CONFIGURED` |
| Ceph/Object Store | Interfaz solo (URI documentado) | ✗ | ✗ | ✗ | ✗ | ✗ | `BLOCKED_EXTERNAL` |
| Mission source (externo) | ✗ | ✗ | ✗ | ✗ | Hechos suministrados por el llamante | ✓ (unit) | `CONTRACTUAL`/`EMULATED` |
| Federation peer | `InProcessTestTransport` | N/A | N/A | ✗ | ✓ (fixture etiquetada TEST_LOCAL) | ✓ | `EMULATED` (explícitamente etiquetado) |
| Cross-domain gateway | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | `BLOCKED_EXTERNAL` |

Ninguna fila anterior se describe como `REAL` externo — coherente con el
estado real (ningún entorno objetivo desplegado, `ENV-QUAL-01` sigue
bloqueado).

---

## 8. Crypto/Trust Truth Matrix

| Mecanismo | Estado | Detalle |
| --- | --- | --- |
| Integridad SHA-256 (hash de contenido) | `IMPLEMENTED_LOCALLY_AND_TESTED` | `evidence_writer`, `federated_artifact.verify_content_hash`, `evidence_root._canonical_hash` — todos recomputan, nunca confían en el campo declarado |
| `EvidenceRoot` (agregación determinista) | `IMPLEMENTED_LOCALLY_AND_TESTED` | Sin Merkle (decisión documentada, ADR-057) |
| Cadena hash de Transparency Log | `IMPLEMENTED_LOCALLY_AND_TESTED` | `LOGICALLY_APPEND_ONLY`/`TAMPER_EVIDENT`, explícitamente NO `IMMUTABLE` |
| `TransparencyReceipt` | `IMPLEMENTED_LOCALLY_AND_TESTED` | Sin firma criptográfica |
| Firma de artefactos | `SPECIFIED`/`BLOCKED_EXTERNAL` | Sin PKI |
| Firma de release | `SPECIFIED`/`BLOCKED_EXTERNAL` | — |
| Firma de Approval | `NOT_IMPLEMENTED` | `ApprovalStore` usa TTL/anti-replay, no firma criptográfica |
| Firma de Tool (`tool_manifest`) | `IMPLEMENTED_LOCALLY_AND_TESTED` (integridad, no firma) | `catalog.manifest.json` con hash, no firma PKI |
| Firma de Model | `NOT_IMPLEMENTED` | Sin mecanismo |
| Firma de Runbook | `BLOCKED_EXTERNAL` | `runbook_signed` estructuralmente `None` en `safety_kernel` — sin Sovereign Root of Trust |
| PKI / Root of Trust | `SPECIFIED`/`BLOCKED_EXTERNAL` | No existe |
| HSM | `NOT_IMPLEMENTED` | No aplica sin PKI |
| Identidad de federación remota | `BLOCKED_EXTERNAL` | Sin segundo sitio real |
| Atestación en runtime | `BLOCKED_EXTERNAL` | `runtime_trust_valid` estructuralmente `None` |
| WORM físico / object-lock | `BLOCKED_EXTERNAL` | Ceph RGW no desplegado |

**Nunca colapsado bajo "confianza criptográfica"** — cada fila es
independiente, tal como exige la reconciliación (§14).

---

## 9. External Blocker Register

| blocker_id | Capacidad afectada | Recurso externo requerido | Qué SÍ se puede probar localmente | Qué NO se puede afirmar | Gate afectado |
| --- | --- | --- | --- | --- | --- |
| BLK-01 | Shuffle/SOAR real | Instancia Shuffle desplegada | Executor in-memory, idempotencia, rollback | Orquestación real de playbooks | G5/G6 |
| BLK-02 | Keycloak | Instancia desplegada | Nada (sin código de integración todavía) | Separación de identidades real (ADR-004) | G0-G7 (transversal) |
| BLK-03 | SPIRE | Instancia desplegada (namespace reservado, ADR-052) | Nada | Identidad de carga de trabajo real | Transversal |
| BLK-04 | OpenBao | Instancia desplegada (namespace reservado) | Nada | Gestión de secretos real | Transversal |
| BLK-05 | Ceph RGW / object-lock | Decisión Rook-Ceph vs. gestionado (DEP-02) + cluster | Hash/integridad lógica | WORM físico, backup/restore real | G6/G7 |
| BLK-06 | Mission source externo | Registro de misión real | `MissionContext` con hechos suministrados por el llamante | Contexto de misión autoritativo end-to-end | K (transversal) |
| BLK-07 | Segundo sitio ARGOS federado | Despliegue de una segunda instancia real | Todo Federation Core/Cross-Domain Core (local) | `REAL_MULTI_SITE_FEDERATION` | L |
| BLK-08 | Identidad de federación | PKI/certificados entre instancias | Nada | `EXTERNAL_FEDERATION_IDENTITY` | L |
| BLK-09 | Pasarela cross-domain real | Infraestructura de red dedicada | `CrossDomainTransfer` lógico | `REAL_CROSS_DOMAIN_GATEWAY` | L |
| BLK-10 | Sovereign Root of Trust / PKI | Autoridad de certificación operativa | Nada | Firma de runbooks/modelos/release, atestación runtime | Transversal (H/J/L) |
| BLK-11 | GitHub Actions org-level | Configuración de Actions a nivel de organización | Validación local (`pytest`/`ruff`/`mypy` en este documento) | CI verde en 4/7 repos vía GitHub | **G0** |
| BLK-12 | Cluster Kubernetes real | `ENV-QUAL-01` | `FakeClusterState`/`FakeReplicaState` | Ejecución/rollback contra infraestructura real, CP00/CP01/CP12 | G6 |

No se inventan fechas de desbloqueo (regla explícita). `BLK-11` es el
único bajo control directo del usuario sin depender de aprovisionar
infraestructura nueva — es también el que bloquea `G0` hoy.

---

## 10. Gap Severity

| Gap | Severidad | Justificación |
| --- | --- | --- |
| `SafetyEnvelope`/Verifier no consumidos por `Gateway.authorize()` (§5) | **CRITICAL** | Invalida el claim de sistema "ninguna ejecución evita el Safety Kernel" — el fallback real (`target_allowlist`+`Approval`) es seguro pero es un camino DISTINTO al declarado por H/K.1 |
| G0 bloqueado por CI org-level | **CRITICAL** (para G0, no para A→L) | Bloquea explícitamente el gate real, ya declarado como tal en `traceability.yaml` |
| `CLAIM-009` obsoleto en assurance ledger | **MAJOR** (corregido en esta reconciliación) | Afirmaba `NOT_SUPPORTED` para Safety Kernel cuando ya existe código real — falso negativo, no falso positivo, pero igualmente una brecha de trazabilidad |
| `maximum_outage` sin semántica de comparación activa | MINOR | Capturado, documentado como `KNOWN_GAP/DEFERRED_POLICY_SEMANTICS` desde Fase K, no oculto |
| Firma criptográfica de evidencia/runbooks/release | EXTERNAL | Depende de PKI que no existe (`BLK-10`) |
| WORM físico | EXTERNAL | Depende de Ceph RGW (`BLK-05`) |
| Federación multi-sitio real | EXTERNAL | Depende de `BLK-07/08/09` |
| Backup/restore OpenSearch/Ceph | DEFERRED_PI3 | `DEP-02` sin decidir, documentado en `traceability.yaml` G6 |
| CP00/CP01/CP12 (cyber-range real) | EXTERNAL | Depende de `ENV-QUAL-01`/`BLK-12` |

`BLOCKED_EXTERNAL` nunca se cuenta como deuda de implementación (regla
§16) — los 9 ítems `EXTERNAL` de la tabla no restan de
`A_L_IMPLEMENTATION_READINESS`.

---

## 11. G0 Activation Matrix

| Requisito | Disponible | Evidencia | Owner | Estado | Bloqueante |
| --- | --- | --- | --- | --- | --- |
| Acta/decisión G0 | ✗ | — | — | `NOT_EVALUATED` | Requiere decisión humana fuera de este repositorio |
| Owners nombrados (personas reales) | ✗ | `repository.yaml` solo tiene roles (`poa-architecture`, etc.) | POA | `NOT_EVALUATED` | Dotación real pendiente |
| Confirmación de capacidad/FTE | ✗ | `governance/raci/raci.md` da FTE recomendado (7,5), no confirmado | POA/DL | `NOT_EVALUATED` | — |
| Acceso a repositorios | ✓ (implícito — este documento se generó con acceso completo a los 7) | git HEAD de los 7 repos (§14) | — | `AVAILABLE` | — |
| Acceso a entorno | Parcial | `ENV-QUAL-01` bloqueado (sin cluster real) | PSE | `PARTIALLY_AVAILABLE` | `BLK-12` |
| `ENV-QUAL-01` | ✗ | `traceability.yaml` G6 | PSE | `BLOCKED` | Cluster real |
| Acceso a datos | ✓ | Fixtures smoke/validation reales en `argos-contracts-scenarios` | XDR | `AVAILABLE` (tier smoke, no acceptance) | — |
| `DataManifest` | ✓ | `argos-contracts-scenarios/fixtures/` con manifest | XDR | `AVAILABLE` | — |
| Contract Pack | ✓ | 11 contratos v1, validados (§6) | PSE | `AVAILABLE` | — |
| Registro OSS | ✓ | `compatibility/oss-admission-registry.yaml`, `test.sh` valida gates≠UNKNOWN | PSE | `AVAILABLE` | — |
| `OSS-QUAL-01` | ✓ (validado por `scripts/test.sh`, verificado en esta reconciliación) | `test OK` (§14) | PSE | `AVAILABLE` | — |
| Cyber-range readiness | Parcial | Manifiestos/namespaces/default-deny reales; sin cluster desplegado | CYB | `PARTIALLY_AVAILABLE` | `BLK-12` |
| Assurance skeleton | ✓ | `assurance/argos-assurance.yaml`, corregido en esta reconciliación (§12) | POA | `AVAILABLE` | — |
| Evidence baseline | ✓ | `EvidenceRoot`/`TransparencyLog` reales (local) | PSE | `AVAILABLE` (local) | — |
| Autoridad de seguridad | ✗ | Sin QSO/SOC designado con nombre real | QSO | `NOT_EVALUATED` | — |
| `DecisionRecord` de G0 | ✗ | No existe | POA | `NOT_EVALUATED` | — |
| CI verde org-level | ✗ | `traceability.yaml`: 4/7 repos bloqueados | PSE | `BLOCKED` | `BLK-11` |
| Calendario M0 | ✗ (futuro) | `gates.md`: M0 = 14 sep 2026; hoy 17 ago 2026 | POA | `NOT_YET_DUE` | — |

**Veredicto G0**: `BLOCKED`. No por falta de código — por falta de
insumos organizativos reales (owners nombrados, decisión de dotación,
CI org-level verde) y porque el propio calendario del proyecto no ha
llegado todavía a M0.

---

## 12. v0.6.26 Candidate Inclusion Matrix

**Nota de trazabilidad previa**: no existe ningún artefacto llamado
"0.6.26" en ningún repositorio (`grep -r "0.6.26"` → 0 resultados en los
7 repos). El único esquema de versión REAL en uso es SemVer por sprint
(`CHANGELOG.md`: "actualizar versión... al finalizar cada sprint"), con
el único release real hoy siendo `0.1.0-dev` (S1/ARG-001). "v0.6.25.x"
es la numeración del **documento maestro externo** (la propuesta de
arquitectura), no una versión de este repositorio. Se trata "v0.6.26"
como la etiqueta de trabajo del usuario para "la próxima versión del
documento maestro que incorporaría esta evidencia real de A→L" — no
como un tag de release de `argos-control`.

| Categoría | Contenido |
| --- | --- |
| `V0626_INCLUDE` | Fases H, J, K, K.1, L completas con evidencia real: Safety Kernel + SafetyEnvelope v1 (producido); Independent Verifier; EvidenceRoot/Transparency Log local; Semantic Cyber Graph; Temporal Knowledge; Mission Context (fuente emulada, documentado); Semantic Conflict; Federation Core/Cross-Domain Core/Federation Policy Engine (local); 683 tests reales, ruff/mypy limpios en 7 repos |
| `V0626_REFERENCE_ONLY` | Executor `increase_monitoring` (real pero sin Shuffle real); integración Mission Context (contractual/emulada); transporte de federación `TEST_LOCAL` — útiles como contexto, no como evidencia de activación G0 |
| `V0626_BLOCKED` | Todo lo que depende de `BLK-01..12` (§9): Shuffle real, Keycloak, SPIRE, OpenBao, Ceph RGW/WORM, PKI/firma, segundo sitio federado, cluster real, CI org-level verde, owners nombrados |
| `V0626_EXCLUDE` | Nada de A→L cae aquí — no hay capacidad especulativa/P1/PI3 construida en este roadmap que deba excluirse; el único candidato a excluir sería backup/restore OpenSearch/Ceph (`DEFERRED_PI3`, ni siquiera empezado) |

**Regla aplicada (§17)**: `v0.6.26` no se genera todavía. Si el
mecanismo de versionado del proyecto permite cortar una versión que
incorpore evidencia real de A→L **sin declarar G0 cerrado**, ese corte
sería legítimo con `G0=BLOCKED` explícito en su manifiesto — pero esa es
una decisión de versionado, no algo que este documento decida por sí
mismo. Ver §15, Decisión final.

---

## 13. Recommended Remediation Backlog

| ID | Hallazgo | Riesgo | Claim/gate afectado | Acción recomendada | Alcance estimado | ARG existente | Candidato ARG nuevo |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **R0-01** | `Gateway.authorize()` no consulta `SafetyEnvelope`/`VerificationResult` | Ejecución real posible sin pasar por Safety Kernel/Verifier | Invariante de seguridad §5 (CRITICAL) | Wire `mcp_gateway.Gateway.authorize()` para exigir un `SafetyEnvelope` `VERIFIED` antes de `execute` en tools con `approval_required` | Medio — 1 punto de integración, tests de regresión en `test_gateway.py` | Ninguno | `ARG-029` candidato (ver §8) o extensión de `ARG-020` |
| **R0-02** | G0 bloqueado por CI org-level | Bloquea `G0` formalmente | G0 | Resolver configuración de GitHub Actions a nivel de organización (acción del usuario, fuera de este repo) | Bajo (config, no código) | — | — |
| R1-01 | `CLAIM-005` (AI sin credenciales) sin test automatizado que falle ante regresión | Deriva silenciosa si se añade un import prohibido | Assurance | Añadir check de arquitectura en CI (p. ej. `import-linter` o test que haga `ast`-grep) | Bajo | Ninguno | — |
| R1-02 | `UNMAPPED_IMPLEMENTATION`: `ADR-053..067` sin ARG | Trazabilidad incompleta backlog↔ADR | Gobernanza | Decisión del usuario: A/B/C (§8) | — | — | `ARG-029+` si opción C |
| R2-01 | `maximum_outage` sin semántica de comparación | Campo capturado pero inerte | Mission Context | Diseñar política de comparación cuando exista una fuente de misión real | Medio, depende de `BLK-06` | Ninguno | — |
| PI3 | Backup/restore OpenSearch/Ceph | Sin script, `DEP-02` sin decidir | G6 | Decidir Rook-Ceph vs. gestionado antes de escribir cualquier script | — | ARG-025 (parcial) | — |
| BLOCKED_EXTERNAL | `BLK-01..12` | Ver §9 | Varios | Ninguna acción posible desde este repositorio | — | — | — |

**R0 = requerido antes de G0** (en este caso, antes de poder afirmar el
invariante de seguridad de sistema, independientemente de G0 formal).
**R1 = requerido antes de Sprint 1/G1** conceptual — en este roadmap,
antes de dar por cerrada la cadena de aseguramiento A→L como sistema, no
solo como módulos. **R2 = antes de un gate MVP posterior.**

---

## 14. Exact Repository Commits and Validation Results

```
generated_at: 2026-08-17
argos-control            92c43257db7eeb57d1a3816587232c34c1b9709b main clean
argos-platform            6062c9f1ce42a5ec080677a99431cfa12721bd59 main clean
argos-contracts-scenarios 7f26630279e3f85027fc6e1734e9127edb920b9a main clean
argos-core                0afbbc74146d6b1fa55bc1d486515fedb1a7b9ec main clean
argos-cyber-tools         186a6bfb2be4d7628e9aee474a619b940afb71a8 main clean
argos-validation          b621a75e08c0b061e7ad20c4101714851f90366b main clean
argos-smartops             62f05ac6a2a5297d17d06036045781d6490448a1 main clean
```

| Repo | Comando | Resultado |
| --- | --- | --- |
| argos-core | `pytest` | 376 passed |
| argos-core | `ruff check .` | All checks passed |
| argos-core | `mypy services connectors` | Success: no issues found in 41 source files |
| argos-cyber-tools | `pytest` | 99 passed |
| argos-cyber-tools | `ruff check .` | All checks passed |
| argos-cyber-tools | `mypy .` | Success: no issues found in 43 source files |
| argos-validation | `pytest` | 138 passed |
| argos-validation | `ruff check .` | All checks passed |
| argos-validation | `mypy .` | Success: no issues found in 47 source files |
| argos-smartops | `pytest` | 70 passed, 1 warning (deprecation, `httpx`) |
| argos-smartops | `ruff check .` | All checks passed |
| argos-smartops | `mypy .` | Success: no issues found in 26 source files |
| argos-contracts-scenarios | `scripts/validate.sh` (schema YAML/JSON) | `validate OK` |
| argos-contracts-scenarios | `scripts/test.sh` (`validate_fixtures.py`) | `validate_fixtures OK — 37 fixtures verificados` |
| argos-platform | `scripts/validate.sh` | `validate (YAML/JSON/repository.yaml) OK` (OpenTofu omitido — `tofu` no instalado en este entorno) |
| argos-platform | `scripts/test.sh` | `test OK` (namespaces Pod Security + default-deny) |
| argos-control | `scripts/validate.sh` | `validate OK` |
| argos-control | `scripts/test.sh` | `test OK` (release-manifest schema, backlog IDs únicos, OSS registry, assurance ledger, AI component registry — todos auto-consistentes) |

**Total tests Python**: 376 + 99 + 138 + 70 = **683**, todos en verde.
**GitHub Actions (org-level)**: `NOT_EVALUATED` en esta reconciliación —
`gh` CLI y acceso de red a `api.github.com` no disponibles en este
entorno de ejecución; se reporta el último estado conocido y fechado
(`traceability.yaml`, mismo día) en vez de asumir que sigue igual o que
se resolvió: **4/7 repos bloqueados, "workflow was not found"** (`BLK-11`).

---

## 15. Final Decision

```
A_L_IMPLEMENTATION_READINESS = GREEN
G0_ACTIVATION_READINESS      = BLOCKED

READINESS OUTCOME: NOT_READY_FOR_V0_6_26_G0_EVIDENCE_UPDATE
```

`G0` depende de insumos organizativos reales (owners nombrados,
decisión de dotación, CI org-level, y un calendario que aún no llega a
M0) que ningún volumen de código A→L puede sustituir. Esto **no es un
fracaso** — es el estado real y verificado del proyecto. `A→L` puede
legítimamente presentarse como evidencia técnica real (`V0626_INCLUDE`,
§12) el día en que el mecanismo de versionado del proyecto decida
cortar una versión, siempre que esa versión declare `G0=BLOCKED`
explícitamente y no "G0 PASS".

**Hallazgo que sí requiere acción antes de cualquier afirmación de
seguridad de sistema** (independiente de G0): `R0-01` — el Safety
Kernel/Independent Verifier no están conectados al gate de ejecución
real. Recomendado resolverlo antes de describir la cadena H→K.1 como
"protegiendo la ejecución" en cualquier documento externo.

---

## STOP

Esta reconciliación no crea Fase M, no crea `ARG-029+`, no genera
`v0.6.26`, no modifica la madurez de ninguna release. Queda a la espera
de aprobación explícita del usuario para cualquiera de esas acciones,
tal como exige el prompt de reconciliación (§30).
