# ADR-064: SecurityDomain y aislamiento tenant/dominio (Fase L)

* **Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado (ver Consecuencia)
* **Fecha**: 2026-08-17
* **Decisores**: Arquitectura (mismo criterio de ADR-051 y siguientes)
* **Historia relacionada**: continuación del roadmap A→L adoptado en ADR-051; identificado en `architecture/v0.6.25-gap-matrix.md`; no reutiliza ni renumera ADR-051..063 (registro inspeccionado antes de asignar número)

## Contexto

El prompt maestro de Federation/Cross-Domain exige un modelo explícito
de dominio de seguridad (tenant/domain/classification/trust_zone) con
la propiedad crítica de que `object.security_domain != target.
security_domain` **nunca** implica transferencia permitida. Ningún
mecanismo de este tipo existía en el repositorio — el `classification`
del envelope común (ADR-001) es un campo por mensaje, no un modelo de
aislamiento tenant/dominio.

## Decisión

`argos-core/services/federation/security_domain.py` implementa
`SecurityDomain` (tenant_id/domain_id/classification/trust_zone/
policy_domain/evidence_domain/knowledge_domain/allowed_federation/
allowed_destinations/retention_profile/export_policy). `classification`
reutiliza el enum real del envelope (`internal`/`confidential`/
`restricted`) — no crea una taxonomía paralela.

`transfer_allowed`/`federation_allowed` son **deny-by-default reales**:
solo permiten lo que `allowed_destinations`/`allowed_federation`
declaran explícitamente, nunca infieren permiso de la ausencia de una
prohibición. Dominios iguales se permiten trivialmente (no es
cross-domain).

## Consecuencia

* No se crea ARG-029+ (ver §34 del prompt de Federation — mapeo contra
  ARG-001..028 sin renumerar ni crear automáticamente).
* Aislamiento cross-tenant/cross-domain verificado con tests explícitos
  (`test_security_domain.py`, `test_federation_decision.py::
  test_cross_tenant_does_not_implicitly_grant_access`,
  `test_federation_adversarial.py::test_cross_tenant_confusion_yields_zero_implicit_access`).

## Impacto sobre AC01-AC14

No aplica — capa de aislamiento nueva, ningún AC existente se relaja.

## Fuentes

`argos-core/services/federation/security_domain.py`,
`argos-core/tests/unit/test_security_domain.py`,
`argos-core/tests/adversarial/test_federation_adversarial.py`.

## Actualización (Reconciliación A→L, 2026-08-17)

`ARG-029` (Sovereign Federation & Cross-Domain Core, epic E9) se creó en
`project/backlog/backlog.yaml` tras la reconciliación global A→L —
alta retroactiva de trazabilidad de backlog para capacidad ya
`IMPLEMENTED_LOCALLY_AND_TESTED`, no trabajo pendiente. No sustituye la
decisión de este ADR ni implica `REAL_MULTI_SITE_FEDERATION`. Ver
`architecture/implementation-readiness.md` §4.1.
