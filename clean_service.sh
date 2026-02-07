#!/usr/bin/env bash

set -euo pipefail

SERVICES=(
  ModemManager
  multipathd
  snapd
  apport
  whoopsie
  bluetooth
  cups
  avahi-daemon
)

echo "==> Desabilitando serviços desnecessários para cloud VM..."

for svc in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^${svc}.service"; then
        echo " -> Parando $svc"
        systemctl stop "$svc" || true

        echo " -> Desabilitando $svc"
        systemctl disable "$svc" || true

        echo " -> Mascando $svc"
        systemctl mask "$svc" || true
    else
        echo " -> $svc não instalado, pulando."
    fi
done

echo
echo "✅ Serviços ajustados."
echo
echo "Reboot recomendado:"
echo "  sudo reboot"
