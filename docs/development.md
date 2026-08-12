# Desarrollo en argos-control

## Requisitos

* `git`, `make`.
* `python3` con `pyyaml` y `jsonschema` para validar `repository.yaml`, `release-manifest.yaml` y los schemas en `releases/schema/`.
* `pre-commit` (opcional pero recomendado): `pre-commit install`.

## Comandos

```bash
make bootstrap   # instala hooks de pre-commit y dependencias locales de validación
make validate    # valida YAML/JSON, repository.yaml, y los ADR frontmatter
make test        # ejecuta las pruebas de scripts/test.sh (validación de schema de release manifest, compatibility, backlog)
```

## Cómo añadir contenido

* **Nuevo ADR**: copiar `templates/adr/ADR-template.md`, numerar correlativo, enlazar desde `adr/README.md` si existe índice.
* **Nueva release**: crear `releases/<version>/release-manifest.yaml` validando contra `releases/schema/release-manifest.schema.json`.
* **Nuevo riesgo**: usar el issue template `architecture-decision.yaml` o `risk.yaml` de `.github/ISSUE_TEMPLATE/`; registrar en `governance/risks/` cuando se ratifique.
* **Estampar la plantilla en otro repositorio**: copiar el contenido de `templates/repository/` al repositorio destino y ajustar `repository.yaml`, `README.md` y `CODEOWNERS` a su dominio.

## Antes de abrir un PR

1. `make validate` sin errores.
2. El PR enlaza una historia `ARG-###` de `project/backlog/backlog.yaml`.
3. Si el cambio afecta a un ADR RESUELTO, se documenta el análisis de impacto sobre AC01-AC14 (`project/acceptance/`).
