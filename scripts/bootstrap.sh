#!/usr/bin/env bash
set -euo pipefail

command -v python3 >/dev/null 2>&1 || { echo "python3 requerido" >&2; exit 1; }

python3 -m pip install --quiet --upgrade pip
python3 -m pip install --quiet pyyaml jsonschema pre-commit

if [ -d .git ]; then
  pre-commit install
fi

echo "bootstrap OK"
