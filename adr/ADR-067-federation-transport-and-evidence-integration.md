# ADR-067: transporte de prueba y evidencia de Federation (Fase L)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura
* **Historia relacionada**: ADR-064, ADR-065, ADR-066; reutiliza ADR-057 (EvidenceRoot/TransparencyLog, Fase J)

## Contexto

El prompt maestro exige separar Federation Core del transporte, y
anclar toda decisión de federación en la evidencia real ya existente
(Fase J) sin crear un subsistema paralelo. No hay un segundo sitio
ARGOS real con el que probar transporte real.

## Decisión

`transport.py`: `FederationTransport` (Protocol) separa el núcleo de
decisión de cualquier transporte concreto. `InProcessTestTransport` es
la ÚNICA implementación real hoy, explícitamente etiquetada
`TEST_LOCAL` (`label.mode`, atributo real, no solo un comentario) —
entrega en memoria, mismo proceso, determinista.

`evidence.py`: reutiliza `evidence_writer.EvidenceWriter` y
`evidence_root.build_evidence_root` tal cual (mismo patrón que
`mission_context.evidence`, ADR-063, Fase K). **Decisión de diseño
explícita**: en vez de ampliar `transparency_log.VALID_EVENT_TYPES`
(Fase J) con ocho constantes de federación nuevas
(`FEDERATED_ARTIFACT_RECEIVED`, `FEDERATION_ACCEPTED`, ...), se sigue
el patrón ya establecido en K.1 — anclar bajo el evento genérico ya
real `EVIDENCE_ROOT_CREATED`, dejando el tipo de decisión real
(`ACCEPT`/`QUARANTINE`/`REJECT`/`RELEASED`/`DENIED`) como contenido del
record ya hasheado, no como un tipo de evento nuevo en el log. Ningún
otro dominio del repositorio (ni siquiera Fase K) tiene eventos propios
en el log — introducirlos solo para Federation habría sido
inconsistente con la convención ya adoptada.

## Consecuencia

* `REAL_TRANSPORT` = `BLOCKED_EXTERNAL` — no se fabrica un peer remoto,
  mTLS real, ni un endpoint STIX-TAXII real para simular que existe.
* `transparency_log.VALID_EVENT_TYPES` no se modifica en esta fase.
* No se crea ARG-029+.

## Impacto sobre AC01-AC14

No aplica.

## Fuentes

`argos-core/services/federation/{transport,evidence}.py`,
`argos-core/tests/unit/test_federation_transport.py`,
`argos-core/tests/integration/test_federation_evidence_integration.py`.

## Actualización (Reconciliación A→L, 2026-08-17)

`ARG-029` (epic E9) creado — alta retroactiva de trazabilidad, no
trabajo pendiente. Ver `architecture/implementation-readiness.md` §4.1.
