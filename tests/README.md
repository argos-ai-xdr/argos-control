# tests

Pruebas de este repositorio (no del XDR). Ejecutadas por `scripts/test.sh` / `make test`:

* Los manifiestos en `releases/*/release-manifest.yaml` validan contra `releases/schema/release-manifest.schema.json`.
* `project/backlog/backlog.yaml` no tiene IDs `ARG-###` duplicados.

Añadir aquí casos de prueba adicionales (p. ej. fixtures de manifiestos inválidos) a medida que crezca `scripts/test.sh`.
