# ADR-016: Política de almacenamiento de evidencia fuera de Git

* **Estado**: RESUELTO PARA BASELINE MVP
* **Fecha**: 2026-08-12 (ratificar en Scope Gate G0, S1)
* **Decisores**: Product Owner/Arquitectura, QA/Security Observer
* **Historia relacionada**: ARG-001, ARG-026

## Contexto

ADR-006 fija el motor del almacén de evidencia (OpenSearch + Ceph RGW). Falta, a nivel de gobierno de repositorios, decidir qué puede y qué no puede vivir en Git a través de los siete repositorios — sin esta regla explícita, es fácil que un fixture de prueba real, un log completo o un manifiesto de evidencia acaben commiteados "porque era rápido".

## Decisión

**Permitido en Git** (todos los repos): fixtures pequeños, ground truth anonimizado, manifiestos de snapshots (hash y metadatos, no el contenido completo), checksums, ejemplos válidos y negativos de contrato.

**Prohibido en Git** (todos los repos): evidencias reales de ejecución, logs completos, capturas PCAP grandes, snapshots CTI completos, modelos, binarios, información clasificada, secretos y credenciales.

Estos objetos se almacenan en Ceph RGW o como artefactos OCI (ADR-006); Git conserva únicamente su digest/hash, referenciado desde `evidence_manifest` en el release manifest (`releases/schema/release-manifest.schema.json`).

## Consecuencia

`.gitignore` de cada repositorio (plantilla en `templates/repository/.gitignore`) excluye por defecto `evidence/`, `reports/generated/` y patrones de secretos. `scripts/validate.sh` de cada repo puede añadir un chequeo de tamaño máximo de archivo (`check-added-large-files`, `.pre-commit-config.yaml`) como control adicional, no como sustituto de esta regla.

## Impacto sobre AC01-AC14

No aplica directamente. Sustenta AC14 (Evidencia/SOC: hashes válidos = 1.00) al garantizar que lo versionado en Git es siempre un hash verificable, nunca el artefacto sensible en sí.

## Fuentes

Documento maestro v0.5, sección 6.5 (reglas de contrato: "sin secretos, tokens, PII ni chain-of-thought") y sección "Datos permitidos/fuera de Git" del bootstrap de `argos-ai-xdr` (2026-08-12). Complementa a ADR-006.
