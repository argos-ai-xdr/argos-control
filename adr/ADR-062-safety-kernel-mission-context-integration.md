# ADR-062: Integración de MissionContext en Safety Kernel (Fase K)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura
* **Historia relacionada**: extiende `safety_kernel` (ADR-054, Fase H) con `mission_context` (ADR-060, Fase K)

## Contexto

Desde ADR-054, `safety_kernel.SafetyCheckInput.mission_impact_bounded`
era una constante `None` hardcodeada — no un parámetro, porque Mission
Context no existía. ADR-060 lo construyó. El prompt exige (K7): "el
Safety Kernel puede consumir mission bounds... pero MissionContext nunca
devuelve ALLOW", y como prueba crítica: "mission impact UNKNOWN + acción
crítica → no SAFE_TO_EVALUATE salvo policy explícita".

## Decisión

`SafetyCheckInput` gana un campo `mission_blast_radius: str | None =
None` (el valor de `mission_context.MissionImpactLevel`). La
comprobación `mission_impact_bounded`:

* `None` o `"INSUFFICIENT_CONTEXT"` → `None` (NOT_EVALUATED) — igual que
  antes cuando no hay dato.
* Cualquier otro valor → `bounded = (valor != "CRITICAL")`. `CRITICAL`
  es SIEMPRE una violación (`BLOCKED`, fail-closed), nunca una nota
  informativa.

**MissionContext sigue sin decidir autorización**: es un hecho más entre
14, exactamente como `blast_radius_bounded`/`tool_digest_valid`. Nunca
se convierte en el campo que aprueba `SAFE_TO_EVALUATE` por sí solo.

## Consecuencia

* De las 14 comprobaciones, ahora 7 (antes 6) son reales-pero-opcionales
  y solo 2 (antes 3) siguen siendo constantes estructurales
  (`runbook_signed`, `runtime_trust_valid`) — medible y probado
  (`test_evaluate_with_mission_blast_radius_supplied_reduces_not_evaluated_to_two`).
* `SAFE_TO_EVALUATE` sigue sin ser alcanzable por ningún checkout real
  de hoy (2 checks siguen en `None`) — correcto, no un defecto.
* `independent_verifier.mission_constraints_respected` NO se toca en
  esta ADR — sigue siendo constante `None`. Es un hueco real distinto
  (ese módulo simplemente no está cableado a `mission_context` todavía),
  documentado en `argos-core/README.md`, no confundir con "Mission
  Context no existe".
* `SafetyEnvelope.mission_bounds` sigue siendo `null` cuando el
  llamante no evaluó MissionContext — no cambia su significado, solo
  deja de ser una constante incondicional.

## Actualización K.1 (2026-08-17): cierra el hueco de `independent_verifier`

El punto anterior queda resuelto: `SafetyEnvelope.mission_bounds` ahora
sella `{mission_blast_radius, mission_context_hash}` cuando
`SafetyCheckInput.mission_blast_radius` se evaluó (campo nuevo
`mission_context_hash` añadido a `SafetyCheckInput`), y
`independent_verifier.mission_constraints_respected` (ver actualización
K.1 en ADR-055) ya re-verifica esa referencia en fresco. Ninguna
autoridad cambia: `mission_bounds` sigue siendo un hecho sellado, nunca
una decisión — `independent_verifier` no recalcula `MissionContext`,
solo confirma que la referencia sellada sigue siendo válida.

## Impacto sobre AC01-AC14

No aplica directamente — endurece la capa de aseguramiento previa a
`PolicyDecision`.

## Fuentes

`argos-core/services/safety_kernel/{__init__.py,README.md}`,
`argos-core/tests/unit/test_safety_kernel.py`,
`argos-core/tests/integration/{test_semantic_mission_vertical_slice.py,test_k1_mission_verifier_vertical_slice.py}`,
`adr/ADR-055-independent-verifier.md` (actualización K.1).
