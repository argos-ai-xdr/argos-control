# Paquete Release/restore (ARG-028)

ARG-028 (S8, propuesta v0.6.25.4 §16.7) define el paquete **"Release/
restore: Install/upgrade/rollback, backup/restore, checksums, SBOM,
firmas y recovery"**, validado por "Rebuild/restore independiente" — y en
su desglose por repositorio (§16.8) fija el artefacto final de
`argos-platform` como **"environment/operations bundle"**. La pieza de
gobierno del release (manifest, schema, validación) vive en
`argos-control`; este documento cubre ambas.

## Install / upgrade / rollback — el modelo de release en sí

`releases/<version>/release-manifest.yaml` + `releases/schema/release-manifest.schema.json`
(ver `releases/README.md`) son el mecanismo REAL: `status` progresa
`dev → candidate → released`, cada transición con requisitos crecientes
(`candidate`/`released` exigen `images`+`contracts`+`validation`
completos, forzado por schema, no por convención). "Rollback" a nivel de
release es volver a un `release-manifest.yaml` anterior — Git es la
única fuente de verdad, consistente con ADR-015: "Argo CD detecta drift
entre el estado declarado... y el reset del cyber-range y el restore de
backup deben quedar reproducibles solo desde Git."

**Estado real hoy**: `0.1.0-dev`, `status: dev`. Ningún componente ha
llegado a `candidate` — cero imágenes construidas, cero digests fijados
(ver `as-built.md`, sección 3).

## Checksums / SBOM / firmas — la pipeline existe, nunca se ha ejecutado

Tres workflows reutilizables reales en `.github/workflows/` de este repo,
no diseño en prosa:

* **`reusable-container-build.yaml`**: build + push, produce un digest
  real como output (`outputs.image-digest`).
* **`reusable-sbom-sign.yaml`**: genera SBOM real (`anchore/sbom-action`,
  CycloneDX o SPDX), firma la imagen con `cosign` (keyless, identidad
  OIDC de GitHub Actions — sin clave privada que gestionar), adjunta el
  SBOM como attestation firmada, y **verifica su propia firma antes de
  terminar** (fail-closed: `cosign verify` + `cosign verify-attestation`
  con `--certificate-identity-regexp "^https://github.com/argos-ai-xdr/"`).
* **`reusable-release-validation.yaml`**: valida un `release-manifest.yaml`
  candidato contra el schema, rechaza cualquier imagen sin
  `@sha256:...` fijo, y verifica la firma `cosign` de CADA imagen
  referenciada.

**Ninguno de los tres se ha ejecutado nunca.** Verificado en los 7 repos:
solo `argos-platform/.github/workflows/ci.yaml` los referencia, y están
**comentados** con la nota explícita "se activan cuando exista el
Dockerfile correspondiente (a partir de ARG-002)". No existe ningún
`Dockerfile` en ningún repositorio de `argos-ai-xdr` (verificado). La
pipeline de checksums/SBOM/firmas no es un diseño aspiracional — es
código real, completo y coherente (fail-closed, keyless, digest-only) —
pero no tiene todavía ninguna imagen real que procesar.

## Backup / restore — BLOCKED, no "falta escribir el script"

Mismo hallazgo que `traceability.yaml` gate G6/ARG-025: OpenSearch sigue
`enabled: false` (`helm/argos-services/values.yaml`) con versión de chart
`"TODO"`, y Ceph RGW no tiene ni siquiera decidido si se despliega
Rook-Ceph self-hosted o un servicio S3 gestionado de OSC (DEP-02). Un
script de backup/restore escrito hoy tendría que inventar contra qué
endpoint/API opera. Se deja `BLOCKED`, mismo principio que ENV-QUAL-01 —
no fabricado.

## Recovery

Cubierto conceptualmente por `cyber-range/reset/reset.sh`
(`argos-platform`, ver
`argos-cyber-tools/docs/cyber-range-package.md`) para el ENTORNO del
escenario — "recovery" del propio release (reconstruir desde cero un
release `released` e inmutable) depende de que primero exista uno, que
todavía no existe.

## Lectura honesta del criterio de validación ("Rebuild/restore independiente")

Un tercero SÍ podría reconstruir el estado ACTUAL del código
(`release-manifest.yaml` fija commits reales y verificables por
repositorio) — pero no podría "restore" nada más allá de eso: no hay
imágenes que descargar, ni backup que restaurar, ni release `candidate`/
`released` que reproducir end-to-end. El paquete queda `NOT EVALUATED`
honestamente — la pipeline que lo haría posible está lista y probada por
inspección, esperando el primer `Dockerfile` real (ARG-002).
