# ADR-021: Independent Verification Barrier (Fase H)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Platform/SRE, Arquitectura (mismo criterio de ADR-017/ADR-020: construir solo lo real y verificable)
* **Historia relacionada**: continuación directa de ADR-020; identificado como el siguiente incremento real de Fase H en `architecture/v0.6.25-gap-matrix.md` §24

## Contexto

El prompt maestro sitúa un "Independent Verifier" entre `SafetyEnvelope`
y `OPA`: no generativo, comprueba `references resolve`, `facts exist`,
`targets exist`, `runbook exists`, `preconditions hold`, `postconditions
measurable`, `rollback executable`, `blast radius bounded`, `mission
constraints respected`. Estados `VERIFIED / INCONCLUSIVE / REJECTED`,
con la regla explícita **"INCONCLUSIVE / REJECTED → ZERO EXECUTE"**.

ADR-020 ya construyó `safety_kernel`, que produce el `SafetyEnvelope`
pero deja explícitamente pendiente su verificación independiente
("cablear OPA directamente a un SafetyEnvelope sin verificación
independiente invertiría el orden del flujo"). Esta ADR resuelve
exactamente ese pendiente.

## Decisión

1. `argos-core/services/independent_verifier` implementa las 9
   comprobaciones sobre hechos **re-consultados en el momento de
   verificar**, no reutilizados del momento en que `safety_kernel`
   construyó el envelope — `preconditions_hold` y `blast_radius_bounded`
   se re-derivan frescos; `runbook_exists` y `rollback_executable` (vía
   `rollback_dry_run_ok`) son señales que `safety_kernel` nunca tuvo
   (ese módulo solo comprobaba `runbook_signed`, siempre `None`, y
   `rollback_supported`, un flag del catálogo, no una prueba real).
2. `mission_constraints_respected` es una constante `None`, igual que
   los 3 checks estructuralmente `None` de `safety_kernel` — Mission
   Context no existe. Consecuencia: **`VERIFIED` no es alcanzable por
   ningún checkout real de hoy**, exactamente el mismo patrón que
   `SAFE_TO_EVALUATE` en ADR-020. `decide_state()` se prueba de forma
   aislada para demostrar que la lógica sí lo alcanza cuando
   corresponda.
3. `INCONCLUSIVE` y `REJECTED` convergen en el mismo efecto práctico
   (`VerificationDecision.zero_execute`), tal como exige el prompt —
   se mantienen como estados distintos solo para auditoría (violación
   conocida vs. hecho no reconfirmable).
4. **No se crea ningún contrato v1 nuevo.** `VerificationResult` no se
   formaliza como contrato cross-repo — nada fuera de `argos-core` lo
   consume todavía, así que darle un schema JSON público sería
   scaffolding sin necesidad real (mismo criterio ya aplicado a
   `ReplayCapsule` en `argos-validation`). Si en el futuro OPA o
   `argos-smartops` necesitaran consumirlo de verdad, se evalúa
   entonces, contrato por contrato, como ya se hizo con SafetyEnvelope.

## Consecuencia

* La cadena real hoy es: `Recommendation` → `Safety Kernel` →
  `SafetyEnvelope` (producido) → `Independent Verifier` (verifica,
  nunca alcanza VERIFIED) → *(OPA todavía no consume nada de esto)*.
  Ningún tramo de esta cadena está fabricado — cada eslabón hace
  exactamente lo que puede hacer honestamente con el estado real del
  sistema, ni más ni menos.
* Security Digital Twin (§25 del gap matrix) sigue sin existir — esta
  ADR no lo construye ni lo simula.
* No se crea ARG-029+: es la extensión directa de la capacidad ya
  identificada en ADR-020 dentro del roadmap adoptado en ADR-017.

## Impacto sobre AC01-AC14

No aplica — capa de aseguramiento adicional antes de `PolicyDecision`;
ningún AC01-AC14 existente se relaja ni se sustituye.

## Fuentes

`argos-core/services/independent_verifier/__init__.py`,
`argos-core/services/independent_verifier/README.md`,
`architecture/v0.6.25-gap-matrix.md` §24,
`adr/ADR-020-safety-kernel-and-safety-envelope-v1.md`.
