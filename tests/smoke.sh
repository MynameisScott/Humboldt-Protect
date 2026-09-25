#!/bin/bash
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
"$ROOT_DIR/scripts/validate.sh"
grep -q 'archive-delete' "$ROOT_DIR/bin/humboldt-protect"
grep -q 'unblock-user' "$ROOT_DIR/bin/humboldt-protect"
grep -q 'unblock-ip' "$ROOT_DIR/bin/humboldt-protect"
grep -q 'HUMBOLDT PROTECT - QUARENTENAS' "$ROOT_DIR/bin/humboldt-protect-quarantine"
grep -q 'Ransomware detectado - contencao aplicada' "$ROOT_DIR/bin/humboldt-protect-watch"
grep -q 'permanent quarantine' "$ROOT_DIR/bin/humboldt-protect-nft-init"
if grep -q 'flags timeout' "$ROOT_DIR/bin/humboldt-protect-nft-init"; then echo 'ERRO: nft init ainda usa timeout' >&2; exit 1; fi
echo "OK: smoke tests concluidos."
