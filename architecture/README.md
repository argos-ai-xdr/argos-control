# Arquitectura autoritativa

Fuente: documento maestro v0.5, sección 6 (Paso 4 — Arquitectura ejecutable, ADRs y backlog). Cualquier cambio aquí que contradiga un ADR RESUELTO requiere abrir un ADR nuevo (ver `../adr/`).

| Carpeta | Contenido |
| --- | --- |
| [`logical/planos.md`](logical/planos.md) | Los seis planos (P1-P6), namespaces y su mapeo a repositorios |
| [`deployment/environments.md`](deployment/environments.md) | Entornos `local`, `laboratory`, `osc` y reglas de fallback |
| [`trust-zones/trust-zones.md`](trust-zones/trust-zones.md) | Zonas de confianza, conectividad permitida y controles |
| [`data-flows/end-to-end-flow.md`](data-flows/end-to-end-flow.md) | Flujo ejecutable extremo a extremo (evento → incidente → recomendación → aprobación → ejecución → evidencia) |
| [`diagrams/repository-topology.md`](diagrams/repository-topology.md) | Diagrama de dependencias entre los 7 repositorios |
