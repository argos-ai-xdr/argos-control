# Desarrollo en {{REPO_NAME}}

## Requisitos

`TODO`: listar el stack real (p. ej. Python 3.12 + FastAPI + Pydantic + NATS, o Node 20 + TypeScript, u OpenTofu + Helm + kubectl).

## Comandos

```bash
make bootstrap   # instala dependencias/hooks locales
make validate    # valida YAML/JSON y repository.yaml
make test        # ejecuta las pruebas del repositorio
```

## Antes de abrir un PR

1. `make validate` y `make test` sin errores.
2. El PR enlaza una historia `ARG-###`.
3. Si el cambio introduce una dependencia nueva, cumple el checklist de licencias (`argos-control/governance/licenses/oss-dependency-policy.md`).
