# ADR-057: EvidenceRoot determinista + Transparency Log local (Fase J)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Platform/SRE, QA/Security Observer (mismo criterio de ADR-051/ADR-054/ADR-055/ADR-056: construir solo lo real y verificable, documentar honestamente lo bloqueado)
* **Historia relacionada**: cierra `CLAIM-010` de `assurance/argos-assurance.yaml` en su ámbito local; continúa el roadmap A→L (Fase J: Evidence/Trust)

## Contexto

El prompt maestro de arquitectura objetivo pide, para Fase J, cerrar el
linaje `Run/Action/Verification → EvidenceManifest → EvidenceRoot →
Transparency record` **sin fabricar** infraestructura criptográfica o de
transparencia que no existe (HSM, PKI de producción, Transparency
service externo, object-lock real). La auditoría previa a esta ADR
confirmó: `EvidenceManifest` ya es real (`evidence_writer`, hash SHA-256
real); `EvidenceRoot` y Transparency Log no existían en absoluto
(`CLAIM-010`, `NOT_SUPPORTED`); el precedente más cercano a un log
append-only real, `argos-smartops/api/audit.py::AuditLog`, no encadena
hashes (no es tamper-evident) y cubre un ámbito distinto (acciones de
operador, no promoción/revocación de componentes).

## Decisión

1. **EvidenceRoot sin Merkle.** Ningún contrato existente exige un árbol
   de Merkle. El precedente ya establecido en este mismo proyecto
   (`argos-validation/harness/acceptance.py::seal_report`) usa hash
   agregado determinista sobre JSON canónico (`sort_keys=True` + sha256)
   — `evidence_root.build_evidence_root` sigue el mismo mecanismo en vez
   de introducir Merkle por sofisticación. `algorithm`/`canonicalization`
   quedan como campos explícitos del payload para no cerrar la puerta a
   crypto-agility futura.
2. **Determinismo real**: mismo conjunto de artefactos (por
   `artifact_id`+`sha256`) → mismo `root_hash`, sin importar el orden de
   entrada (se reordena por `sha256` antes de hashear); cualquier cambio
   en cualquier artefacto cambia el root. Duplicados exactos se
   deduplican; duplicados conflictivos (mismo `artifact_id`, distinto
   `sha256`) siempre lanzan error — nunca se resuelven en silencio.
   `critical=True` (por defecto) rechaza cualquier evidencia ausente en
   vez de aceptar un `UNKNOWN`.
3. **Transparency Log local, `LOGICALLY_APPEND_ONLY / TAMPER_EVIDENT`,
   nunca `IMMUTABLE`.** `TransparencyLog` expone una única vía pública de
   mutación (`append`); cada entrada encadena
   `previous_entry_hash == hash(entrada anterior)` y su propio
   `entry_hash`. `verify_chain()` detecta mutación histórica, huecos de
   secuencia y enlaces rotos recomputando desde cero — nunca confiando
   en el campo que ya trae el dato. Persistencia opcional a JSONL con
   `open(path, "a")` real. Se documenta explícitamente que esto NO es
   almacenamiento inmutable real (object-lock/WORM de Ceph RGW no existe,
   ARG-026) — es tamper-evidencia lógica, detectable, no
   irreversibilidad física.
4. **TransparencyReceipt sin firma.** No declara ningún campo de firma
   criptográfica — Sovereign Root of Trust no existe (ARG-002/ARG-020).
   Permite verificar objeto→evento→secuencia→estado de cadena en el
   momento de emisión.
5. **Sin contrato v1 nuevo.** `EvidenceRoot`/`TransparencyReceipt` no se
   formalizan como contrato cross-repo — nada fuera de `argos-core` los
   consume todavía (mismo criterio ya aplicado a `ReplayCapsule` en
   ADR-055). Si una fase futura necesita consumirlos desde otro
   repositorio, se evalúa entonces, contrato por contrato.
6. **Vertical slice real, no simulado.** El ciclo completo
   (`request → execute → verify → rollback → EvidenceManifest →
   EvidenceRoot → Transparency entry`) se demuestra con las 3 acciones
   `execute` reales de Fase I (`isolate_kubernetes_workload`,
   `scale_to_zero`, `increase_monitoring`) — los `ActionResult` usados
   son la salida LITERAL de invocar el código real de
   `argos-cyber-tools`, no fixtures inventados.

## Consecuencia

* `CLAIM-010` (`assurance/argos-assurance.yaml`) pasa de `NOT_SUPPORTED`
  a `PARTIALLY_SUPPORTED`: el linaje evidencia→root→transparencia es
  real y probado en ámbito local; sigue sin existir firma real,
  almacenamiento WORM físico ni un servicio de transparencia externo.
* Explícitamente `BLOCKED_EXTERNAL`/`SPECIFIED`, no construidos aquí:
  HSM, offline root CA, hardware-backed attestation, confidential
  computing, Transparency service externo, Sigstore privado, PKI de
  producción, post-quantum, object-lock real.
* No se crea ARG-029+: es la extensión directa de la capacidad ya
  identificada (`EvidenceManifest`) dentro del roadmap adoptado en
  ADR-051.
* Estado final de la fase: **`PHASE_J_IMPLEMENTED_LOCALLY_AND_TESTED`**
  — explícitamente NO `VALIDATED_IN_TARGET` ni `PRODUCTION_READY` (sin
  infraestructura objetivo desplegada).

## Impacto sobre AC01-AC14

Sustenta AC14 (Evidencia/SOC: hashes válidos = 1.00) con una capa de
agregación e integridad adicional sobre `EvidenceManifest`; ningún
AC01-AC14 existente se relaja ni se sustituye.

## Fuentes

`argos-core/services/evidence_root/{__init__.py,transparency_log.py,replay.py,README.md}`,
`argos-core/tests/{unit/test_evidence_root.py,unit/test_transparency_log.py,unit/test_replay.py,unit/test_evidence_j_invariants.py,integration/test_evidence_vertical_slice.py,security/test_evidence_writer_is_sole_writer.py,fixtures/action-results/}`,
`argos-validation/harness/acceptance.py::seal_report` (precedente del mecanismo de hash agregado),
`argos-smartops/api/audit.py::AuditLog` (precedente distinto, sin hash-chain),
`assurance/argos-assurance.yaml` CLAIM-010,
`adr/ADR-006-evidence-store.md`, `adr/ADR-016-evidence-storage-policy.md`.
