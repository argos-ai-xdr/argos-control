# ADR-068: Chaos Engineering & Chaos Monkey Validation Profile

**Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado a `argos-validation`+`argos-platform`, plano de validación, nunca camino productivo.

**Fecha**: 2026-08-18. **Fase**: M (Resiliencia/Validación continua) — posterior a la reconciliación global A→L (`ADR-051..067`, cerrada `FEATURE_FREEZE_A_L=TRUE` el 2026-08-17 sobre SU PROPIO alcance). Este ADR no reabre ni modifica ningún ADR de Fase A→L; es la siguiente decisión de arquitectura, decidida explícitamente por el usuario el 2026-08-18.

## Contexto

ARGOS no tenía hasta ahora ninguna capacidad de *fault injection* — solo `evaluators/resilience` (`argos-validation`, AC13) que evalúa evidencia YA producida (idempotencia entre reintentos), no un mecanismo que perturbe activamente el sistema para observar su comportamiento real bajo fallo. El cierre de R0-01/R0-01-RESIDUAL (2026-08-18, `argos-cyber-tools`) demostró el valor de esta disciplina — un hallazgo de seguridad solo se considera cerrado cuando existe una prueba que ejecuta el fallo de verdad, no solo un análisis estático — y motivó extenderla a resiliencia: ¿sigue conteniéndose el impacto (fail-closed, zero execute, sin duplicación) cuando además del ataque hay un fallo real de infraestructura (reinicio, partición de red, caída de un componente crítico)?

## Decisión

### Herramienta: Chaos Mesh (P0), no Chaos Monkey de Netflix

ARGOS es Kubernetes/GitOps nativo (ver `architecture/logical/planos.md`, `argos-platform/kustomize`). El Chaos Monkey oficial de Netflix (`Netflix/chaosmonkey`) está diseñado para terminar instancias y requiere gestionar las aplicaciones con Spinnaker — dependencia que ARGOS no tiene ni planea adoptar en el baseline. [Chaos Mesh](https://chaos-mesh.org/) es una plataforma cloud-native para Kubernetes vía CRDs (`PodChaos`, `NetworkChaos`, `DNSChaos`, `HTTPChaos`, workflows, RBAC/namespace scoping) — encaja de forma nativa con el resto de `argos-platform`.

Se adopta:

* **P0**: Chaos Mesh + un **perfil de comportamiento "Chaos Monkey"** (terminación aleatoria de pods/workloads en el cyber-range) implementado SOBRE Chaos Mesh (`PodChaos` con selector aleatorio), no como dependencia de `Netflix/chaosmonkey`.
* **P1/opcional, no comprometido**: `Netflix/chaosmonkey` real, únicamente si Spinnaker llegara a formar parte de la plataforma real — no se afirma que esté desplegado hasta entonces.

En documentación se usa el nombre **"Chaos Engineering & Chaos Monkey Validation Profile"** — nunca se afirma que `Netflix/chaosmonkey` esté desplegado.

### Frontera de seguridad — invariante no negociable

Chaos Engineering es una **herramienta de validación**, nunca un camino de ejecución productivo. No puede entrar, ni accidentalmente, por `Recommendation → Approval → MCP → production`:

```text
CHAOS TOOL  ≠  SOAR  ≠  MCP EXECUTOR  ≠  production action
```

Autorización fail-closed (mismo patrón que `mcp_gateway.Gateway.authorize`, R0-01): un experimento de caos solo se autoriza si TODO lo siguiente es cierto —

```text
environment ∈ {cyber-range, test, integration}
AND chaos_enabled == true
AND namespace ∈ chaos_allowlist
AND max_parallel_experiments no excedido
AND experiment declara: experiment_id, hypothesis, target,
    expected_steady_state, blast_radius, duration,
    abort_conditions, recovery_procedure
```

Cualquier ausencia o inconsistencia → `DENY`. Un experimento de caos **nunca reutiliza las autorizaciones productivas de ARGOS** (ninguna `Approval`/`SafetyEnvelope` de `mcp_gateway` autoriza ni es autorizada por un experimento de caos — son espacios de autorización disjuntos).

### Ubicación en el monorepo de 7 repos

No se crea un repositorio nuevo (ver `ADR-014`, topología cerrada). Vive en los dos repos ya responsables de validación e infraestructura:

```text
argos-validation/chaos/     — safety guard (autorización fail-closed),
                               catálogo de escenarios (CHAOS-01..20)
argos-platform/chaos/       — Chaos Mesh (Helm), RBAC, namespace scoping,
                               NetworkPolicy deny-by-default para el
                               chaos-controller-manager
```

### Ciclo de vida de un experimento

```text
BEFORE (steady-state snapshot) → INJECT (fault) → OBSERVE (telemetría/
alertas/comportamiento ARGOS) → VERIFY (invariante esperado) → RECOVER
(baseline) → EVIDENCE (EvidenceManifest/EvidenceRoot/TransparencyReceipt/
ReplayCapsule, Fase J)
```

### Catálogo de escenarios (CHAOS-01..20)

Declarados como manifiestos reales en `argos-validation/chaos/scenarios/` (campos obligatorios: `experiment_id`, `hypothesis`, `target`, `expected_steady_state`, `blast_radius`, `duration`, `abort_conditions`, `recovery_procedure`). Cubren: fallo de componentes core (`argos-core`, correlador), fallo de sensores (Wazuh, Falco), fallo de bus (NATS), partición de red, fallo de cada eslabón de la cadena de seguridad post-R0-01 (OPA, Approval, Independent Verifier, Safety Kernel — todos deben producir `zero execute`, nunca fail-open), fallo de Evidence Store/Transparency Log, fallo de Milvus/LLM (fallback determinista No-RAG), reinicio del MCP Gateway (sin replay de acciones), y el caso derivado directamente de la correlación Falco/Wazuh de hoy (`ARG-015`/`ARG-016`, ver `architecture/notes/falco-wazuh-correlation.md`): 50 alertas Falco de subproceso + reinicio del correlador durante la ventana de deduplicación → debe seguir produciendo 1 `Incident`, no 50 ni una fusión incorrecta de dos ataques distintos.

**Caos específico sobre R0-01/R0-01-RESIDUAL** (`CHAOS-16`, `argos-cyber-tools/tests/adversarial/test_chaos_16_gateway_restart_r0_01_regression.py`): reinicio del `mcp_gateway` a mitad de un flujo `SafetyEnvelope → VerificationResult → Approval → execute`, modelado honestamente como una instancia NUEVA de `Gateway`/`ApprovalStore` (mismo efecto que perder el estado en memoria de un proceso reiniciado). Dos hallazgos distintos, verificados EJECUTANDO el reinicio, no solo argumentados:

1. **Sobrevive** (test real, en verde): la reutilización de `Approval`/`SafetyEnvelope` de un incidente A bajo el contexto de un incidente B sigue denegándose tras el reinicio — el binding de R0-01-RESIDUAL (`current_plan_hash`↔`envelope_hash`) es puramente funcional de cada `ToolCallRequest`, no depende de ningún estado que un reinicio pueda perder.
2. **NO sobrevive con `ApprovalStore` (en memoria)** (test real, `xfail` intencional y documentado, no oculto): una `Approval` ya consumida con éxito ANTES del reinicio puede volver a consumirse en la instancia nueva, porque `ApprovalStore._consumed` es memoria de proceso, no un almacén compartido. **Cerrado 2026-08-18** (`argos-cyber-tools/policies/approval/durable_store.py`, `DurableApprovalStore`, SQLite): el mismo escenario, inyectando `DurableApprovalStore` en vez del `ApprovalStore` por defecto, SÍ deniega el replay tras reinicio (`test_chaos_16_ch07_closed_with_durable_approval_store`, en verde) — consumo atómico real (`INSERT` con `approval_id` como `PRIMARY KEY`, probado con 5 consumidores concurrentes: exactamente 1 éxito, 4 `REPLAY_DENIED`), fail-closed si el propio almacén no responde (`ApprovalStorageUnavailable`, subclase de `ApprovalRejected` — el gateway ya lo trata como `DENY` sin código nuevo). **Matiz importante, no ocultado**: `Gateway.__init__` sigue usando `ApprovalStore()` (en memoria) POR DEFECTO si no se inyecta explícitamente uno durable — el núcleo durable existe y está probado, pero ningún despliegue real lo usa todavía porque no existe ningún despliegue real (`DURABLE_APPROVAL_CORE=IMPLEMENTED_LOCALLY_AND_TESTED`, `TARGET_APPROVAL_BACKEND=BLOCKED_EXTERNAL/NOT_SELECTED` -- SQLite demuestra el contrato, no es la elección de backend de producción para un gateway multi-réplica real).

### Quality gates nuevos — familia `CH-*`

Declarados aquí (no en `project/acceptance/acceptance-criteria.yaml`, que es contenido literal del docx v0.5 §5.6 — `CH-*` es contenido nuevo de este ADR, mismo patrón que R0/R1/R2 en `architecture/implementation-readiness.md` §13):

| ID | Umbral | Crítico |
| --- | --- | --- |
| CH-01 | Ejecución de caos en producción = 0 | sí |
| CH-02 | Inyección en namespace no autorizado = 0 | sí |
| CH-03 | Fallo crítico de control-plane → fail-closed = 100% | sí |
| CH-04 | Acción denegada durante caos → `executor_call_count` = 0 | sí |
| CH-05 | Recuperación a steady-state = 100% en escenarios P0 definidos | no |
| CH-06 | Efectos secundarios duplicados tras reinicio = 0 | sí |
| CH-07 | Replay de `Approval` tras reinicio = 0 | sí — **`PASS_LOCALLY` con `DurableApprovalStore`** (`CHAOS-16`, cerrado 2026-08-18); `ApprovalStore` en memoria (todavía el valor por defecto de `Gateway`) sigue `KNOWN_FAILING` salvo que se inyecte explícitamente el almacén durable |
| CH-08 | Completitud de evidencia = 1.00 | no |
| CH-09 | Reproducibilidad de `ReplayCapsule` = 1.00 | no |
| CH-10 | Fallo Milvus/LLM → fallback determinista = PASS | sí |
| CH-11 | Visibilidad de pérdida de telemetría = 1.00 | no |
| CH-12 | `UNKNOWN` crítico convertido silenciosamente en `SAFE` = 0 | sí |

**Estado inicial de todos los `CH-*`**: `NOT_EVALUATED` — no hay clúster de caos real desplegado todavía (mismo patrón que `SAFE_TO_EVALUATE`/Sovereign Root of Trust en `CLAIM-009`: declarar un gate no es afirmar que pasa). Excepción, ambos con prueba local real (`CHAOS-16`, ver más arriba): `CH-04` = `PASS` (zero execute cross-incident sobrevive al reinicio) y `CH-07` = `PASS_LOCALLY` (2026-08-18, `DurableApprovalStore`) siempre que se inyecte explícitamente — `KNOWN_FAILING` sigue siendo el comportamiento real del `Gateway()` por defecto, que no se ha cambiado (ARG-020, target backend de producción sin seleccionar todavía). El resto de `CH-*` sí necesita un clúster real (`BLOCKED_EXTERNAL`, mismo bloqueo que ya afecta a `ARG-021`/Shuffle).

## Consecuencias

* No se afirma ninguna capacidad de caos "desplegada en OSC" ni "validada en target" — todo lo construido en esta fase es `IMPLEMENTED_LOCALLY_AND_TESTED` cuando es código puro (safety guard, tests) o `BLOCKED_EXTERNAL`/`NOT_EVALUATED` cuando depende de un clúster real (mismo vocabulario que `traceability/implementation-readiness.yaml` §3).
* `governance/backlog` gana epic `E10` (Resiliencia) con historias mapeadas a este ADR (ver `project/backlog/backlog.yaml`).
* No reabre `G0`/`v0.6.26` — es evidencia técnica adicional, no una condición de activación.
