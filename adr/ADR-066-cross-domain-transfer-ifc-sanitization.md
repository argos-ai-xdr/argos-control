# ADR-066: CrossDomainTransfer, IFC y sanitización determinista (Fase L)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura
* **Historia relacionada**: ADR-064, ADR-065

## Contexto

El prompt maestro exige un pipeline real de liberación cross-domain
(Source → Domain Policy → IFC → Deterministic Sanitization →
Classification Check → Approval when required → CrossDomainTransfer →
Destination), confirmando explícitamente que **no existía ningún
mecanismo de IFC/taint previo** en el repositorio ("integrate with
existing (none exists)"). También exige que ningún LLM pueda
desclasificar de forma autoritativa.

## Decisión

`ifc.py`: `evaluate_ifc` es una función pura, determinista, que
produce `ALLOW`/`DENY`/`SANITIZE`/`REQUIRE_APPROVAL` basándose
exclusivamente en `security_domain.CLASSIFICATION_LEVELS` y
`transfer_allowed` (ADR-064) — sin invocar generación. Pedir liberar
bajo una etiqueta MENOS restrictiva que la original (`requested_rank <
original_rank`) siempre produce `REQUIRE_APPROVAL`, nunca `ALLOW`/
`SANITIZE` automático — cierra explícitamente el ataque de "downgrade"
del prompt (§29).

`sanitizer.py`: `apply_sanitization` implementa las 5 transformaciones
del prompt (`REMOVE_FIELD`/`REDACT_FIELD`/`TOKENIZE_FIELD`/
`GENERALIZE_VALUE`/`DROP_ATTACHMENT`) sobre una copia profunda —
determinista (mismo payload + misma política produce siempre el mismo
`released_hash`), con test explícito de regresión de datos ocultos
(un campo duplicado en una ruta anidada no declarada por la política
sigue presente hasta que la política la cubre de forma explícita — no
hay detección "mágica").

`cross_domain_transfer.py`: `CrossDomainTransfer` v1 con el pipeline
completo. `DENIED`/`PENDING_APPROVAL` nunca liberan hash ni payload;
`RELEASED` solo tras aprobación explícita (`approver_ref` YA
suministrado — nunca inferido por este módulo) cuando la política lo
exige.

## Consecuencia

* No se crea ARG-029+.
* Ningún campo de texto libre puede sobreescribir el resultado de la
  política de clasificación — verificado en
  `test_federation_ifc.py::test_requested_classification_must_be_a_real_enum_value`.

## Impacto sobre AC01-AC14

No aplica.

## Fuentes

`argos-core/services/federation/{ifc,sanitizer,cross_domain_transfer}.py`,
`argos-core/tests/unit/{test_federation_ifc,test_federation_sanitizer,test_cross_domain_transfer}.py`.
