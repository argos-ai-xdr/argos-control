# Releases

Cada carpeta `releases/<version>/release-manifest.yaml` fija los commits (y, a partir de `candidate`, las imágenes por digest, versiones de contrato y evidencia de validación) que forman una release reconstruible de `argos-ai-xdr`.

* Schema: [`schema/release-manifest.schema.json`](schema/release-manifest.schema.json).
* Validación automática: `reusable-release-validation.yaml` (workflow reutilizable) y `../scripts/test.sh` localmente.
* `status: dev` — en construcción, solo commits, sin imágenes ni release candidate.
* `status: candidate` — release candidate; requiere `images`, `contracts` y `validation` completos.
* `status: released` — aceptada (gate G7); inmutable.

Historial: [`0.1.0-dev/`](0.1.0-dev/) — ARG-001, S1.

Paquetes ARG-028: [`0.1.0-dev/as-built.md`](0.1.0-dev/as-built.md),
[`0.1.0-dev/release-restore-package.md`](0.1.0-dev/release-restore-package.md).

**Nota**: escribir siempre `created_at` entre comillas (`"2026-08-12T16:39:00Z"`). Sin comillas, PyYAML lo interpreta como `datetime` nativo en vez de `string` y la validación contra el schema falla.
