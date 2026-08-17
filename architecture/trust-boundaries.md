# Trust boundaries (datos y decisión)

ADR-051, Fase A. Complementa a [`trust-zones/trust-zones.md`](trust-zones/trust-zones.md),
que cubre CONECTIVIDAD DE RED (qué origen puede hablar con qué destino,
por qué protocolo). Este documento cubre otra dimensión: qué pasa con
un DATO o una DECISIÓN al cruzar cada frontera de servicio — validación,
preservación de origen, recomputación independiente, integridad. No
duplica la tabla de red; cítala, no la repite.

## Regla general

Ninguna frontera de servicio confía en la forma de un payload por venir
de dentro del propio proceso o de un caller ya autenticado por la capa
de red. Cada frontera reaplica su propia validación de contenido.

## Fronteras reales y qué se aplica al cruzarlas

### 1. Cualquier productor → contrato v1 (schema validation en cada frontera)

Todo mensaje que cruza una frontera de servicio (normalizer→NATS,
NATS→correlator, cualquier servicio→evidence, etc.) se valida contra
su JSON Schema v1 antes de aceptarse — no se confía en que el productor
ya lo validó. Prueba real: `argos-core/tests/contract/test_producer_outputs_validate.py`
valida la salida de cada productor contra su schema; `argos-contracts-scenarios/fixtures/negative/`
contiene fixtures que deben ser rechazados (p.ej. `missing-event-id.json`).
Aplicación real en `normalizer/__init__.py`: "Rechaza explícitamente lo
que no cumple — nunca deja pasar un evento sin `schema_version`/`native_ref`."

### 2. `native_ref` — preservación de origen a través de todo el pipeline

Cada evento normalizado conserva `native_ref` (referencia al evento
original en el sistema fuente: Wazuh, CrowdStrike, etc.), inmutable
desde la ingesta. Aplicación real: `normalizer/__init__.py:77` (`native_ref: str`,
campo obligatorio del `RawEvent`); `dedup_key = (raw.source, raw.native_ref)`
lo usa para deduplicación estable — si `native_ref` se perdiera o se
regenerara en una frontera intermedia, la dedup se rompería
silenciosamente. `argos_envelope` propaga `native_ref` en el envelope
para que cualquier consumidor aguas abajo pueda trazar un evento
normalizado hasta su origen exacto (ADR-001).

### 3. `plan_hash` — recomputación independiente, no propagación confiada

`plan_hash` se deriva SIEMPRE de `(tool, target, action, params)` con
JSON canónico (`sort_keys=True`, sin espacios) + SHA-256. La frontera
crítica: **existen dos implementaciones independientes de
`compute_plan_hash`**, una en `argos-cyber-tools/policies/approval/__init__.py`
(el validador, en el momento de `authorize()`) y otra en
`argos-smartops/api/approvals.py` (el emisor, en el momento de crear la
Approval) — el comentario en el propio código lo declara explícitamente:
*"Idéntica a argos-cyber-tools/policies/approval.compute_plan_hash — ver
[nota]"*. `mcp_gateway.Gateway.authorize()` exige `current_plan_hash`
como parámetro obligatorio y lo recalcula/compara en su propio proceso
— nunca confía en un `plan_hash` que ya venga adjunto sin recomputarlo
del lado validador. Esto es intencional: si `argos-smartops` fuera
comprometido y falsificara un `plan_hash`, `argos-cyber-tools` lo
detectaría porque no importa el valor, lo recalcula.

`compute_signature_ref` (`sha256(approval_id:plan_hash)`) es un
checksum de integridad, explícitamente NO una firma criptográfica real
(sin KMS/clave privada del aprobador — ARG-020 pendiente). Documentado
así en el propio código para que nadie lo confunda con una firma en
producción.

### 4. `evidence_writer` — integridad de contenido, no solo de tránsito

Cada objeto de evidencia se hashea con SHA-256 real sobre su contenido
en el momento de escribirse (`evidence_writer/__init__.py:49`,
`hashlib.sha256(content).hexdigest()`), y el hash forma parte del
`object_ref` (`ceph://.../{sha256[:12]}`) — el nombre del objeto
depende de su propio contenido, así que un objeto modificado después de
escrito no coincide con su referencia. Esto es integridad de contenido
en reposo, no una cadena de custodia firmada ni un Transparency Log
append-only (`CLAIM-010`, `NOT_SUPPORTED` en `../assurance/argos-assurance.yaml`)
— la distinción importa: hoy se puede detectar que un objeto cambió si
alguien recalcula el hash y lo compara, pero no hay un registro
inmutable de terceros que lo haga automáticamente ni firma que
identifique quién lo escribió.

## Lo que NO existe, explícitamente

* **Information Flow Control / Taint Tracking**: no existe ningún
  mecanismo que etiquete un dato como "derivado de una fuente no
  confiable" y bloquee su uso en una decisión aguas abajo sin
  sanitización explícita. Hoy la única barrera es la validación de
  schema en cada frontera (§1) — binaria (pasa/no pasa el schema), no
  un análisis de procedencia por dato. No inventar esta capacidad: es
  un hueco real, ya reflejado en que ningún claim del ledger de
  assurance la menciona como `SUPPORTED`.
* **Cifrado de campos sensibles en tránsito entre servicios internos
  más allá de TLS de red** (i.e., un trust boundary de cifrado a nivel
  de campo/payload): no existe; lo que hay es TLS/mTLS a nivel de
  conexión, ya cubierto en `trust-zones/trust-zones.md`, no una
  frontera de datos adicional.

## Fuentes

`argos-core/services/normalizer/__init__.py`,
`argos-core/libs/argos_envelope/__init__.py`,
`argos-core/services/evidence_writer/__init__.py`,
`argos-cyber-tools/policies/approval/__init__.py`,
`argos-cyber-tools/mcp_gateway/__init__.py`,
`argos-smartops/api/approvals.py`,
`argos-core/tests/contract/test_producer_outputs_validate.py`,
`adr/ADR-001-event-envelope.md`, `assurance/argos-assurance.yaml`,
`architecture/trust-zones/trust-zones.md`.
