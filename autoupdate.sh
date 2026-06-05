#!/usr/bin/env bash
#
# setup-auto-updates.sh
# Ativa o unattended-upgrades no Ubuntu e agenda um update forçado
# diariamente às 03:37 via systemd timer.
#
# Uso: sudo ./setup-auto-updates.sh
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "ERRO: execute como root (sudo $0)" >&2
    exit 1
fi

echo "==> [1/5] Instalando pacotes necessários..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq unattended-upgrades apt-listchanges update-notifier-common

echo "==> [2/5] Habilitando atualizações automáticas (20auto-upgrades)..."
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

echo "==> [3/5] Configurando unattended-upgrades (50unattended-upgrades)..."
cat > /etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
    "${distro_id}:${distro_codename}-updates";
};

// Remove dependências órfãs e kernels antigos
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Reboot automático se necessário (ex: kernel novo), no horário definido
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";

// Logs detalhados em /var/log/unattended-upgrades/
Unattended-Upgrade::SyslogEnable "true";
EOF

echo "==> [4/5] Criando service + timer systemd para update forçado às 03:37..."

cat > /etc/systemd/system/forced-update.service <<'EOF'
[Unit]
Description=Update forcado do servidor (apt full-upgrade + unattended-upgrade)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
Environment=DEBIAN_FRONTEND=noninteractive
ExecStart=/usr/bin/apt-get update
ExecStart=/usr/bin/apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade
ExecStart=/usr/bin/unattended-upgrade -v
ExecStart=/usr/bin/apt-get -y autoremove --purge
ExecStart=/usr/bin/apt-get -y autoclean
TimeoutStartSec=2h
EOF

cat > /etc/systemd/system/forced-update.timer <<'EOF'
[Unit]
Description=Executa update forcado diariamente as 03:37

[Timer]
OnCalendar=*-*-* 03:37:00
# Se o servidor estava desligado no horário, roda assim que ligar
Persistent=true
# Pequeno jitter para evitar thundering herd se houver vários servidores
RandomizedDelaySec=60

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now forced-update.timer

echo "==> [5/5] Validando configuração..."
systemctl status forced-update.timer --no-pager || true
echo
echo "Próximas execuções agendadas:"
systemctl list-timers forced-update.timer --no-pager
echo
echo "Teste de dry-run do unattended-upgrades:"
unattended-upgrade --dry-run --debug 2>&1 | tail -n 5 || true

echo
echo "=========================================================="
echo " Configuração concluída!"
echo "  - unattended-upgrades: ATIVO (security + updates)"
echo "  - Update forçado: todo dia às 03:37 (systemd timer)"
echo "  - Reboot automático (se necessário): 04:00"
echo
echo " Comandos úteis:"
echo "   systemctl list-timers forced-update.timer   # próxima execução"
echo "   journalctl -u forced-update.service         # logs do update"
echo "   tail -f /var/log/unattended-upgrades/unattended-upgrades.log"
echo "=========================================================="
