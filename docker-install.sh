#!/usr/bin/env bash
set -euo pipefail

# =========================
# Docker Server Bootstrap
# Ubuntu (20.04+ recomendado)
# =========================

# Ajuste se quiser outro usuário além do que está logado via sudo
DOCKER_USER="${SUDO_USER:-${USER}}"

echo "==> Instalando pré-requisitos..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

echo "==> Removendo pacotes conflitantes (se existirem)..."
# (seguro rodar mesmo se não existirem)
apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "==> Adicionando chave GPG do repositório Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "==> Adicionando repositório Docker..."
ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"

cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable
EOF

echo "==> Instalando Docker Engine + plugins (buildx/compose)..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Pacotes oficiais recomendados no doc :contentReference[oaicite:1]{index=1}

echo "==> Configurando /etc/docker/daemon.json (defaults server)..."
install -d /etc/docker

# Mantém simples e útil:
# - log rotation para evitar /var/lib/docker encher (log-opts como string) :contentReference[oaicite:2]{index=2}
# - live-restore ajuda a manter containers rodando se o daemon reiniciar :contentReference[oaicite:3]{index=3}
cat >/etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "5"
  },
  "live-restore": true
}
EOF

echo "==> Habilitando e iniciando serviços..."
systemctl enable --now docker
systemctl enable --now containerd

echo "==> Adicionando usuário ao grupo docker (para usar sem sudo)..."
if getent group docker >/dev/null 2>&1; then
  usermod -aG docker "${DOCKER_USER}" || true
fi

echo
echo "=============================="
echo " STATUS FINAL"
echo "=============================="
docker --version || true
docker compose version || true
systemctl status docker --no-pager || true

echo
echo "✅ Docker instalado e servidor pronto."
echo "IMPORTANTE: para o usuário '${DOCKER_USER}' usar docker sem sudo,"
echo "faça logout/login (ou reinicie a sessão/servidor)."
