#!/bin/bash
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Execute como root: sudo ./scripts/install.sh" >&2
  exit 2
fi

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

install -d -m 700 /etc/humboldt-protect
install -d -m 700 /var/lib/humboldt-protect

getent group humboldt_quarantine >/dev/null 2>&1 || groupadd --system humboldt_quarantine

for f in humboldt-protect humboldt-protect-watch humboldt-protect-contain humboldt-protect-quarantine humboldt-protect-nft-init humboldt-dash-notify; do
  install -o root -g root -m 750 "$ROOT_DIR/bin/$f" "/usr/local/sbin/$f"
done

install -o root -g root -m 644 "$ROOT_DIR/systemd/humboldt-protect.service" /etc/systemd/system/humboldt-protect.service

if [ ! -e /etc/humboldt-protect/config.json ]; then
  install -o root -g root -m 600 "$ROOT_DIR/config/humboldt-protect.example.json" /etc/humboldt-protect/config.json
  echo "Criado /etc/humboldt-protect/config.json a partir do exemplo. EDITE antes de iniciar o servico."
fi

if [ ! -e /etc/humboldt-protect/dash-notify.env ]; then
  install -o root -g root -m 600 "$ROOT_DIR/config/dash-notify.env.example" /etc/humboldt-protect/dash-notify.env
  echo "Criado /etc/humboldt-protect/dash-notify.env. Configure URL/token antes de usar notificacoes."
fi

systemctl daemon-reload

echo
echo "Instalacao-base concluida."
echo "1) Edite /etc/humboldt-protect/config.json"
echo "2) Crie /etc/humboldt-protect/borg.passphrase com chmod 600"
echo "3) Configure Samba full_audit e invalid users conforme docs/SAMBA_AUDIT.md"
echo "4) Valide: sudo humboldt-protect check"
echo "5) Inicie: sudo systemctl enable --now humboldt-protect.service"
