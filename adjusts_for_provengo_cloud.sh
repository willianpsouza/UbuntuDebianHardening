#!/usr/bin/env bash

set -euo pipefail

NTP_SERVERS=("10.16.0.135" "10.16.0.134")
PROXIES=("10.16.0.135:3128" "10.16.0.134:3128")
DNS_SERVERS=("10.16.0.135" "10.16.0.134")

TIMEZONE="America/Sao_Paulo"

echo "=============================="
echo " Cloud base tuning - Ubuntu"
echo "=============================="

############################
# Timezone
############################
echo "==> Ajustando timezone para $TIMEZONE"
timedatectl set-timezone "$TIMEZONE"

############################
# NTP / timesyncd
############################
echo "==> Configurando systemd-timesyncd"

mkdir -p /etc/systemd/timesyncd.conf.d

cat >/etc/systemd/timesyncd.conf.d/local.conf <<EOF
[Time]
NTP=${NTP_SERVERS[*]}
FallbackNTP=
EOF

systemctl restart systemd-timesyncd
timedatectl set-ntp true

############################
# Proxy global
############################
echo "==> Configurando proxy"

cat >/etc/profile.d/proxy.sh <<EOF
export http_proxy="http://${PROXIES[0]}"
export https_proxy="http://${PROXIES[0]}"
export HTTP_PROXY="http://${PROXIES[0]}"
export HTTPS_PROXY="http://${PROXIES[0]}"
EOF

chmod +x /etc/profile.d/proxy.sh

############################
# APT proxy
############################
echo "==> Configurando proxy do apt"

cat >/etc/apt/apt.conf.d/95proxy <<EOF
Acquire::http::Proxy "http://${PROXIES[0]}";
Acquire::https::Proxy "http://${PROXIES[0]}";
EOF

############################
# systemd proxy
############################
echo "==> Configurando proxy para systemd"

mkdir -p /etc/systemd/system.conf.d

cat >/etc/systemd/system.conf.d/proxy.conf <<EOF
[Manager]
DefaultEnvironment="http_proxy=http://${PROXIES[0]}" \
                   "https_proxy=http://${PROXIES[0]}"
EOF

systemctl daemon-reexec

############################
# DNS via systemd-resolved
############################
echo "==> Configurando DNS"

mkdir -p /etc/systemd/resolved.conf.d

cat >/etc/systemd/resolved.conf.d/local.conf <<EOF
[Resolve]
DNS=${DNS_SERVERS[*]}
FallbackDNS=
Domains=~.
EOF

systemctl restart systemd-resolved

############################
# Status final
############################
echo
echo "=============================="
echo " STATUS FINAL"
echo "=============================="

timedatectl status | grep -E "Time zone|NTP service"
resolvectl status | head -20

echo
echo "✅ Configuração concluída."
echo "Reboot recomendado:"
echo "  sudo reboot"
