# Runbook: {{NOMBRE_DE_LA_ACCIÓN}}

* **Repositorio propietario**: `TODO` (normalmente `argos-cyber-tools`)
* **Herramienta MCP asociada**: `TODO` (nombre y versión del tool catalog)
* **Estado**: BORRADOR | APROBADO POR SOC/CYBER | RETIRADO
* **Aprobado por** (SOC/Cyber, ver `argos-control/governance/raci/raci.md`): `TODO`
* **Fecha de aprobación / última simulación**: `TODO`

## Cuándo se usa

`TODO`: qué tipo de incidente/recomendación dispara este runbook (referenciar `Incident`/`Recommendation` y, si aplica, caso C-06/C-07/C-08).

## Modos soportados

- [ ] read-only
- [ ] dry-run
- [ ] execute (reversible)

## Precondiciones y límites (obligatorio, DoR)

* **Target allowlist**: `TODO` — el runbook nunca actúa fuera de esta lista.
* **Impacto máximo**: `TODO`
* **Timeout**: `TODO` segundos
* **Kill switch**: `TODO` — cómo se interrumpe en caliente
* **Idempotencia**: `TODO` — clave de idempotencia y comportamiento si se reintenta

## Pasos

1. **Dry-run**: `TODO`
2. **Aprobación (HITL)**: rol requerido, `TODO`; TTL de la aprobación, `TODO`
3. **Ejecución**: `TODO`
4. **Verificación**: `TODO` — cómo se confirma que el efecto fue el esperado
5. **Rollback** (si falla la verificación o se activa el kill switch): `TODO`

## Evidencia producida

Referenciar los campos del contrato `ActionResult` y `EvidenceManifest` (ver `argos-control/compatibility/contracts.yaml` y `../evidence/evidence-manifest-template.json`): `action_id`, `idempotency_key`, `changed_resources`, `verification`, `rollback_ref`.

## Historial de simulación (rollback rehearsal)

| Fecha | Resultado | Evidencia (run_id) |
| --- | --- | --- |
| `TODO` | `TODO` | `TODO` |

El runbook debe simularse (rollback rehearsal) al menos dos veces antes de aprobarse para S6 (Definition of Done del paso 3, documento maestro v0.5).
