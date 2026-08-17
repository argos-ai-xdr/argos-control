# ADR-054: Deterministic Safety Kernel y SafetyEnvelope v1 (Fase H)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Platform/SRE, Arquitectura (siguiendo el criterio de ADR-051: construir solo lo real y verificable; SafetyEnvelope v1 es el ejemplo que ADR-051 cita explícitamente para una futura excepción contrato-por-contrato)
* **Historia relacionada**: identificado en `architecture/v0.6.25-gap-matrix.md` §1 y §21-25 como la pieza de mayor valor de seguridad por esfuerzo del roadmap A→L, y confirmado como tal por el usuario tras completar las Fases A-G

## Contexto

El prompt maestro de arquitectura objetivo especifica un "Deterministic
Safety Kernel" situado entre `Recommendation` y `OPA/Policy`: determinista,
no generativo, que valida 14 condiciones (Incident valid, Evidence
sufficient, Target exists, Target in scope, Tool ACTIVE, Tool digest
valid, Runbook signed, Action reversible, Rollback available, Blast
radius bounded, Mission impact bounded, RuntimeTrustContext valid, No
unresolved critical drift, No prohibited action) y produce un
`SafetyEnvelope v1` (19 campos) con estados `SAFE_TO_EVALUATE / BLOCKED
/ INCONCLUSIVE / ESCALATE`. El propio prompt insiste: **SAFE_TO_EVALUATE
≠ APPROVED**.

`architecture/v0.6.25-gap-matrix.md` §21-25 confirmó que Safety Kernel,
SafetyEnvelope, Independent Verifier y Security Digital Twin no
existían: cero código, cero tests, cero contrato. De las 14
comprobaciones, solo 5-11 son honestamente evaluables con el estado real
del sistema hoy — 3 (`Runbook signed`, `Mission impact bounded`,
`RuntimeTrustContext valid`) dependen de subsistemas que el propio gap
matrix ya marca como inexistentes (Sovereign Root of Trust, Mission
Context, RuntimeTrustContext).

## Decisión

1. Se construye `argos-core/services/safety_kernel` como Deterministic
   Safety Kernel real: las 14 comprobaciones se implementan todas, pero
   cada una recibe su hecho del LLAMANTE (`SafetyCheckInput`) — nunca se
   fabrica un resultado. `runbook_signed`, `mission_impact_bounded` y
   `runtime_trust_valid` son **constantes `None`** en el código (no
   parámetros que alguien pudiera rellenar con un valor optimista):
   ningún llamante de hoy puede aportarlos honestamente.
2. Estados alcanzables hoy: `BLOCKED` (fail-closed, cualquier violación
   conocida) e `INCONCLUSIVE` (sin violaciones pero con checks sin
   evaluar). `SAFE_TO_EVALUATE` es alcanzable **por la lógica**
   (`decide_state()`, probado de forma aislada) pero no por ningún
   checkout real de hoy, porque siempre hay al menos 3 checks en `None`.
   Esto es la consecuencia correcta y esperada del estado real del
   sistema, no un defecto de la implementación.
3. `ESCALATE` queda en el tipo `SafetyKernelState` (el prompt lo exige)
   pero ningún camino del código lo produce: exigiría una señal de
   anomalía catastrófica que ningún subsistema real emite hoy.
   Especificado, no alcanzable — documentado así explícitamente, no
   fabricado con un trigger arbitrario.
4. **SafetyEnvelope v1 se añade como contrato 11** en
   `argos-contracts-scenarios/schemas/safety-envelope/`, con fixture
   smoke real generada invocando el código real (no escrita a mano).
   Esto es una excepción explícita al conjunto cerrado de 10
   (documento maestro §6.5) — pre-autorizada por ADR-051, que cita
   textualmente "SafetyEnvelope v1 para Fase H" como el ejemplo de
   cuándo un contrato nuevo se evalúa y ratifica de forma individual, no
   como parte de los ~32 contratos nuevos del prompt en bloque.
5. `signature` en el envelope es un checksum sha256 de integridad, NO
   una firma criptográfica real — mismo patrón y misma limitación ya
   documentados en `policies/approval.compute_signature_ref`
   (Sovereign Root of Trust no existe, ARG-002/ARG-020 pendientes).

## Consecuencia

* **El SafetyEnvelope se produce pero no se consume todavía.** Ningún
  código de `policy_adapter`/`mcp_gateway` lo lee ni lo exige — cablear
  esa integración ahora invertiría el propio flujo del prompt
  (`Recommendation → Safety Kernel → SafetyEnvelope → Independent
  Verifier → OPA → HITL`): OPA no debe consumir un SafetyEnvelope que
  ningún Independent Verifier ha vetado todavía, y ese componente
  tampoco existe. Ese cableado es el siguiente incremento real de Fase
  H, no este.
* Independent Verifier y Security Digital Twin (§24-25 del gap matrix)
  siguen sin existir — esta ADR no los construye ni los simula.
* No se crea ningún ARG-029+ para este trabajo: es la extensión de una
  capacidad ya identificada (Safety Kernel) dentro del roadmap ya
  adoptado (ADR-051), no una historia nueva independiente.
* El conjunto de 10 contratos cerrados no cambia de estado — sigue
  siendo cerrado; SafetyEnvelope es la ÚNICA excepción y quedó
  documentada como tal en tres lugares (`compatibility/contracts.yaml`,
  `argos-contracts-scenarios/schemas/README.md`, esta ADR), no en
  silencio.

## Impacto sobre AC01-AC14

No aplica — SafetyEnvelope no sustituye ni relaja ningún AC01-AC14
existente; es una capa de aseguramiento adicional antes de
`PolicyDecision`, que sigue siendo la que decide `ALLOW_DRY_RUN`/
`APPROVAL_REQUIRED`/`DENY`.

## Fuentes

`argos-core/services/safety_kernel/__init__.py`,
`argos-core/services/safety_kernel/README.md`,
`argos-contracts-scenarios/schemas/safety-envelope/v1.schema.json`,
`architecture/v0.6.25-gap-matrix.md` §1, §21-25,
`adr/ADR-051-incremental-v0625-roadmap-adoption.md`,
`adr/ADR-053-tool-manifest-v1-secure-lifecycle.md` (mismo criterio de
excepción contrato-por-contrato, aplicado ahí a un schema interno en
vez de a un contrato cross-repo).
