# Cómo usar esta plantilla

Esta carpeta es la estructura mínima homogénea que deben tener los 6 repositorios funcionales de `argos-ai-xdr` (`argos-platform`, `argos-contracts-scenarios`, `argos-core`, `argos-cyber-tools`, `argos-validation`, `argos-smartops`). Ver ADR-014 y ADR-015.

## Pasos para estampar en un repositorio nuevo o existente

1. Copiar todo el contenido de esta carpeta (excepto este `README.md`) a la raíz del repositorio destino.
2. Renombrar `README.template.md` a `README.md` y rellenar `{{REPO_NAME}}`, `{{MISSION}}` y la tabla de contenido con la información real del repositorio (ver la sección correspondiente del documento maestro v0.5 / plan de bootstrap).
3. Editar `repository.yaml`: `name`, `domain`, `criticality`, `owner`, `backup_owner`, `dependencies` (repos de `argos-ai-xdr` de los que depende, ver `../../adr/ADR-014-repository-topology.md`).
4. Editar `CODEOWNERS` con los roles reales que aplican a ese repositorio (subconjunto de `../../governance/raci/raci.md`).
5. Ajustar `docs/architecture.md` y `docs/development.md` al stack real del repositorio (Python/FastAPI, Node/TypeScript, OpenTofu/Kubernetes, etc.).
6. Referenciar los workflows reutilizables de `argos-control` en `.github/workflows/ci.yaml` (ver `.github/workflows/README.md` de esta plantilla).
7. No editar `.github/ISSUE_TEMPLATE/` ni `.github/pull_request_template.md` salvo que el repositorio necesite un campo adicional — mantenerlos iguales entre repos reduce fricción.

No copiar `../adr/`, `../../governance/`, `../../releases/`, `../../compatibility/` ni `../../project/` — esos viven solo en `argos-control` y se consultan por referencia, no se duplican.
