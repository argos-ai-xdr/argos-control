# argos-control

Repositorio de gobierno e integración de la organización **argos-ai-xdr**. No contiene código funcional del XDR: contiene las decisiones, controles, releases y mecanismos compartidos que permiten integrar el resto de repositorios.

Fuente de la propuesta: `ARGOS_Propuesta_Tecnica_Maestro_Vivo_v0.5.docx` (baseline de propuesta, 12/08/2026). Cualquier discrepancia entre este repositorio y una versión posterior del documento maestro debe resolverse abriendo un ADR o una excepción, nunca editando el histórico en silencio.

## Organización

```text
argos-ai-xdr/
├── argos-control              (este repositorio)
├── argos-platform
├── argos-contracts-scenarios
├── argos-core
├── argos-cyber-tools
├── argos-validation
└── argos-smartops
```

Orden de construcción: `argos-control` → `argos-platform` → `argos-contracts-scenarios` → `argos-validation` → `argos-core` → `argos-cyber-tools` → `argos-smartops`.

## Contenido de este repositorio

| Carpeta | Contenido |
| --- | --- |
| `architecture/` | Arquitectura autoritativa: planos lógicos, despliegue, zonas de confianza y flujos de datos |
| `adr/` | Registro de decisiones de arquitectura (ADR-001 en adelante) |
| `governance/` | RACI, gates G0-G7, riesgos, excepciones, política de licencias OSS y políticas de segregación de funciones |
| `releases/` | Manifiesto de releases y su schema |
| `compatibility/` | Matriz de compatibilidad de contratos, componentes y entornos |
| `templates/` | Plantilla de repositorio, ADR, runbook y evidencia — se estampa en los otros 6 repos |
| `project/` | Backlog (ARG-001–ARG-028), definición de sprints S1-S8 y criterios de aceptación AC01-AC14 |
| `.github/workflows/` | Workflows reutilizables (`workflow_call`) consumidos por los demás repositorios |

## Responsabilidades

* Arquitectura autoritativa y ADR-001 en adelante.
* RACI operativo y segregación de funciones.
* Registro de riesgos y excepciones.
* Workflows reutilizables de CI/CD.
* Reglas de calidad comunes (SBOM, firma, SemVer, digest).
* Manifiesto de releases y matriz de compatibilidad.
* Estado de los gates G0-G7 y de los hitos M0-M8.
* Paquete de aceptación y handover final.
* Coordinación del proyecto S1-S8.

## Reglas comunes a toda la organización

* Rama principal: `main`. Sin rama permanente `develop`.
* Ramas de trabajo: `feat/ARG-007-netbox-adapter`.
* Pull request obligatorio; revisión de `CODEOWNERS`; checks de CI obligatorios.
* Prohibido push directo, force-push y borrado de `main`.
* Versionado SemVer; imágenes OCI referenciadas por digest; SBOM CycloneDX/SPDX; firma con Cosign.
* Ningún secreto, evidencia generada o dataset sensible en Git.
* Todo evento conserva `run_id`, `trace_id` y `evidence_refs`.
* Todo cambio arquitectónico enlaza un ADR; todo PR enlaza una historia `ARG-###`.

## Primeras tareas (ARG-001)

Ver `project/backlog/backlog.yaml`. Definition of Done de `argos-control` en `governance/gates/gates.md` (gate G0 / Scope Gate de S1).
