# Contribuir a {{REPO_NAME}}

1. Toda historia debe existir como issue `ARG-###` (ver `argos-control/project/backlog/backlog.yaml`) antes de abrir una rama.
2. Rama de trabajo: `feat/ARG-###-descripcion-corta`, `fix/...`.
3. Pull request obligatorio contra `main`. Sin push directo, force-push ni borrado de `main`.
4. Todo PR debe enlazar la historia `ARG-###`, pasar CI y respetar `CODEOWNERS`.
5. Todo cambio que implique una decisión de arquitectura nueva (no solo implementación) se propone como ADR en `argos-control` antes o junto con el PR de código.
6. No incluir secretos, credenciales, PII ni datasets sensibles (ver `SECURITY.md`).

Ver `docs/development.md` para comandos y flujo local.
