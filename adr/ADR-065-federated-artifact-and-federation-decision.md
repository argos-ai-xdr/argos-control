# ADR-065: FederatedArtifact y evaluación local de confianza (Fase L)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura
* **Historia relacionada**: ADR-064 (SecurityDomain); `architecture/v0.6.25-gap-matrix.md`

## Contexto

Principio central del prompt maestro de Federation: **"la federación
transporta información, nunca autoridad"**. Ninguna instancia remota de
ARGOS puede conceder de forma remota un `ALLOW` de OPA, una `Approval`
de HITL, validez de `SafetyEnvelope`, autoridad de ejecución, ni
promoción local a `ACTIVE`. Se necesitaba: (1) un formato real para
intercambiar inteligencia externa sin heredar autoridad, y (2) una
evaluación local de confianza que decida qué hacer con ese artefacto
sin nunca ejecutar nada.

## Decisión

`federated_artifact.py`: `FederatedArtifact` v1 con hash de contenido
determinista y verificable (`verify_content_hash` recomputa desde el
payload real, nunca confía en el campo declarado — mismo principio que
`evidence_root.verify_evidence_root`, ADR-057). **Invariante aplicado
en código, no solo documentado**: `build_federated_artifact` rechaza
`origin_trust=AUTHORITATIVE` (`ForbiddenDefaultTrust`) — esa etiqueta
solo puede asignarla una decisión LOCAL posterior. También valida
`origin_classification` contra el enum real al construir (cerrado tras
un hallazgo real de la suite adversarial: antes solo se detectaba en
`decision.py`, no en el punto de ingesta).

`ledger.py`/`revocation.py`: anti-replay real (`FederationLedger`,
mismo artifact_id + hash distinto = `ContentConflict`, nunca
sobrescritura silenciosa) y revocación real sin método para
"des-revocar" (`RevocationRegistry`).

`decision.py`: `evaluate_federation` produce `FederationDecision`
(`ACCEPT`/`QUARANTINE`/`REJECT`/`LOCAL_REVALIDATION_REQUIRED`)
evaluando 12 dimensiones de confianza **sin promediar** — cualquier
violación conocida pesa más que cualquier cantidad de dimensiones OK
(mismo criterio fail-closed que `safety_kernel`/`independent_verifier`,
ADR-054/055). Reutiliza `semantic_conflict.resolve_conflict` (ADR-061,
Fase K) para el eje semántico/de misión — sin motor de conflictos
paralelo. **`ACCEPT != ACTIVE`**: `FederationDecision.is_active` es
siempre `False`, expuesto como propiedad real (no solo un comentario)
para que un test pueda afirmarlo.

## Consecuencia

* Ninguna decisión de federación puede, por sí sola, activar ejecución
  local — probado estructuralmente en
  `test_federation_safety_vertical_slice.py`.
* No se crea ARG-029+.

## Impacto sobre AC01-AC14

No aplica.

## Fuentes

`argos-core/services/federation/{federated_artifact,ledger,revocation,decision}.py`,
`argos-core/tests/unit/{test_federated_artifact,test_federation_ledger_and_revocation,test_federation_decision}.py`,
`argos-core/tests/adversarial/test_federation_adversarial.py`.
