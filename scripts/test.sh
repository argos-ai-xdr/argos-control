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

if errors:
    print("TEST FALLIDO:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)

print("test OK")
PY
