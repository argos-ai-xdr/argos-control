#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
import pathlib
import sys

import yaml
from jsonschema import validate, ValidationError
import json

root = pathlib.Path(".")
errors = []

# Every release manifest under releases/<version>/ must validate against the schema.
schema_path = root / "releases/schema/release-manifest.schema.json"
if schema_path.exists():
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    for manifest in root.glob("releases/*/release-manifest.yaml"):
        data = yaml.safe_load(manifest.read_text(encoding="utf-8"))
        try:
            validate(instance=data, schema=schema)
        except ValidationError as exc:
            errors.append(f"{manifest}: no valida contra el schema: {exc.message}")
else:
    errors.append("releases/schema/release-manifest.schema.json no existe")

# Backlog: IDs ARG-### únicos.
backlog_path = root / "project/backlog/backlog.yaml"
if backlog_path.exists():
    backlog = yaml.safe_load(backlog_path.read_text(encoding="utf-8")) or {}
    items = backlog.get("items", [])
    ids = [i.get("id") for i in items]
    dupes = {i for i in ids if ids.count(i) > 1}
    if dupes:
        errors.append(f"project/backlog/backlog.yaml: IDs duplicados {sorted(dupes)}")
else:
    errors.append("project/backlog/backlog.yaml no existe")

# OSS-QUAL-01: registro de admisión OSS — cada fila debe tener los 6
# campos obligatorios y un gate válido; ninguna fila UNKNOWN entra en la
# release candidata (regla dura del documento maestro v0.6.25.4, §2.3.1).
oss_path = root / "compatibility/oss-admission-registry.yaml"
VALID_GATES = {"ADMIT", "ADMIT_WITH_OBLIGATIONS", "REJECT"}
REQUIRED_TOP_FIELDS = ("identidad", "licencia", "supply_chain", "operacion_soberana", "sostenibilidad", "gate")
if oss_path.exists():
    registry = yaml.safe_load(oss_path.read_text(encoding="utf-8")) or {}
    components = registry.get("components", [])
    if not components:
        errors.append("compatibility/oss-admission-registry.yaml no declara ningún componente")
    names = [c.get("componente") for c in components]
    dupes = {n for n in names if names.count(n) > 1}
    if dupes:
        errors.append(f"compatibility/oss-admission-registry.yaml: componentes duplicados {sorted(dupes)}")
    for component in components:
        label = component.get("componente", "<sin nombre>")
        missing = [f for f in REQUIRED_TOP_FIELDS if not component.get(f)]
        if missing:
            errors.append(f"oss-admission-registry: {label} sin campo(s) obligatorio(s) {missing}")
        gate = component.get("gate")
        if gate not in VALID_GATES:
            errors.append(f"oss-admission-registry: {label} tiene gate={gate!r}, debe ser uno de {sorted(VALID_GATES)} (UNKNOWN no es admisible)")
        spdx_id = (component.get("licencia") or {}).get("spdx_id")
        if not spdx_id:
            errors.append(f"oss-admission-registry: {label} sin licencia.spdx_id")
else:
    errors.append("compatibility/oss-admission-registry.yaml no existe")

if errors:
    print("TEST FALLIDO:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)

print("test OK")
PY
