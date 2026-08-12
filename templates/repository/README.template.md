# {{REPO_NAME}}

{{MISSION}}

Parte de la organización [`argos-ai-xdr`](https://github.com/argos-ai-xdr). Ver la arquitectura autoritativa y las decisiones (ADR) en [`argos-control`](https://github.com/argos-ai-xdr/argos-control).

## Contenido

| Carpeta | Contenido |
| --- | --- |
| `TODO` | `TODO` |

## Reglas comunes de la organización

* Rama principal: `main`. Sin rama permanente `develop`.
* Pull request obligatorio; revisión de `CODEOWNERS`; checks de CI obligatorios.
* Prohibido push directo, force-push y borrado de `main`.
* Versionado SemVer; imágenes OCI referenciadas por digest; SBOM CycloneDX/SPDX; firma con Cosign.
* Ningún secreto, evidencia generada o dataset sensible en Git (ver ADR-016 de `argos-control`).
* Todo evento conserva `run_id`, `trace_id` y `evidence_refs`.
* Todo cambio arquitectónico enlaza un ADR (en `argos-control`); todo PR enlaza una historia `ARG-###`.

Ver `docs/development.md` para cómo trabajar en este repositorio.
