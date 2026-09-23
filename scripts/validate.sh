#!/bin/bash
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
python3 -m py_compile "$ROOT_DIR/bin/humboldt-protect" "$ROOT_DIR/bin/humboldt-protect-watch" "$ROOT_DIR/bin/humboldt-dash-notify"
bash -n "$ROOT_DIR/bin/humboldt-protect-contain"
bash -n "$ROOT_DIR/bin/humboldt-protect-nft-init"
bash -n "$ROOT_DIR/scripts/install.sh"
echo "OK: validacao sintatica concluida."
