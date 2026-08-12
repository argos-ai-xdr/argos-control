# Política de seguridad — argos-control

## Alcance

Este repositorio no ejecuta código productivo ni almacena secretos, evidencias generadas ni datasets. Contiene decisiones de arquitectura, plantillas y manifiestos versionados en texto plano.

## Reglas obligatorias (aplican a los 7 repositorios de argos-ai-xdr)

* Ningún secreto, credencial, token, PII, prompt sensible o chain-of-thought en Git, issues o PRs.
* Ninguna dependencia comercial puede ser crítica para la aceptación (ADR-013). Toda dependencia declara licencia, versión/digest, SBOM, owner y sustituto.
* Toda imagen de contenedor referenciada por otros repositorios se fija por digest y se firma con Cosign.
* IBM X-Force queda excluido del diseño (ADR-007); no se reintroduce sin nuevo ADR y revisión de licencia/soberanía.

## Reporte de vulnerabilidades o hallazgos

* Vulnerabilidades en el propio contenido de gobierno (p. ej. un workflow reutilizable con permisos excesivos): abrir un issue `exception.yaml` o `risk.yaml` y notificar al QA/Security Observer (rol `qa-security-observer` en CODEOWNERS).
* Vulnerabilidades en componentes desplegados: reportar en `argos-platform` o `argos-cyber-tools` según corresponda; no documentar detalles de explotación en issues públicos del repositorio.
* Excepciones de seguridad tienen caducidad obligatoria (ver `governance/exceptions/`) y no pueden ser aprobadas por quien las solicita (segregación de funciones, `governance/policies/segregation-of-duties.md`).

## Segregación de funciones

Ningún rol puede autoaprobar una excepción de la que sea ejecutor. QA/Security Observer puede bloquear cualquier gate G0-G7 (`governance/gates/gates.md`).
