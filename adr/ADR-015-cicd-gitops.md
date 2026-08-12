# ADR-015: CI/CD centralizado y despliegue GitOps

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, Platform/SRE, Delivery Lead
* **Historia relacionada**: ARG-001, ARG-002

## Contexto

Con siete repositorios (ADR-014) y un equipo de 7,5 FTE, siete pipelines de CI/CD distintos y mantenidos de forma independiente consumirían capacidad que el backlog no tiene (211 SP candidatos, 180 SP P0). El estado de despliegue de `argos-platform` tampoco puede depender de comandos manuales si se quiere reset reproducible del cyber-range (ARG-003) y recuperación auditable.

## Decisión

* CI: los seis repositorios funcionales consumen los workflows reutilizables (`workflow_call`) publicados en `argos-control/.github/workflows/`: `reusable-python-ci`, `reusable-node-ci`, `reusable-iac-ci`, `reusable-container-build`, `reusable-sbom-sign`, `reusable-release-validation`. No se duplica lógica de CI repo a repo.
* CD: Argo CD en `argos-platform` como único mecanismo de despliegue (GitOps); no se aplican cambios manuales (`kubectl apply` ad hoc) contra los entornos `local`, `laboratory` u `osc`.
* Reglas comunes: rama principal `main` sin `develop`, PR obligatorio, prohibido push directo/force-push/borrado de `main`, checks de CI obligatorios, revisión de `CODEOWNERS`.

## Consecuencia

Un cambio en la política de SBOM/firma (p. ej. añadir un scanner de licencias) se hace una vez en `argos-control` y se propaga a los seis repos en su siguiente ejecución de CI, en lugar de seis PRs coordinados. A cambio, `argos-control` se convierte en dependencia crítica de CI: un workflow reutilizable roto bloquea el pipeline de toda la organización, por lo que sus propios cambios requieren revisión reforzada (`CODEOWNERS`: `@platform-sre`).

Argo CD detecta drift entre el estado declarado en `argos-platform` y el estado real del clúster; el reset del cyber-range y el restore de backup deben quedar reproducibles solo desde Git.

## Impacto sobre AC01-AC14

No aplica directamente. Sustenta AC01 (Reproducibilidad: dos ejecuciones limpias producen el mismo conjunto de hechos) al eliminar despliegues manuales no versionados.

## Fuentes

Documento maestro v0.5, sección 3 (Reglas comunes) y sección 6.11 (repositorios y release manifest); `governance/gates/gates.md` (G0-G1).
