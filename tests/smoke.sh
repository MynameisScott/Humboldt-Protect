#!/bin/bash
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
"$ROOT_DIR/scripts/validate.sh"
grep -q 'archive-delete' "$ROOT_DIR/bin/humboldt-protect"
grep -q 'Ransomware detectado - contencao aplicada' "$ROOT_DIR/bin/humboldt-protect-watch"
grep -q 'tcp dport' "$ROOT_DIR/bin/humboldt-protect-nft-init"
echo "OK: smoke tests concluidos."
