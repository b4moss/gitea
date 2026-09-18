#!/bin/bash
# Managed by Terraform — disposable Gitea smoke host.
set -euo pipefail
exec > >(tee -a /var/log/gitea-smoke-startup.log) 2>&1

IMAGE="${image}"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl jq docker.io docker-compose-v2
systemctl enable --now docker

# Wait for external IP (sslip.io host for Let's Encrypt)
EXT_IP=""
for _ in $(seq 1 60); do
  EXT_IP="$(curl -fsS -H 'Metadata-Flavor: Google' \
    http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip || true)"
  if [[ -n "$${EXT_IP}" ]]; then
    break
  fi
  sleep 2
done
if [[ -z "$${EXT_IP}" ]]; then
  echo "failed to resolve external IP" >&2
  exit 1
fi

SMOKE_HOST="$${EXT_IP}.sslip.io"
ROOT_URL="https://$${SMOKE_HOST}/"
echo "SMOKE_HOST=$${SMOKE_HOST}"
echo "ROOT_URL=$${ROOT_URL}"
echo "IMAGE=$${IMAGE}"

AR_HOST="$(echo "$${IMAGE}" | cut -d/ -f1)"
ACCESS_TOKEN="$(curl -fsS -H 'Metadata-Flavor: Google' \
  'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token' | jq -r .access_token)"
echo "$${ACCESS_TOKEN}" | docker login -u oauth2accesstoken --password-stdin "https://$${AR_HOST}"

docker pull "$${IMAGE}"

mkdir -p /opt/gitea-smoke /data/gitea
cat > /opt/gitea-smoke/Caddyfile <<EOF
$${SMOKE_HOST} {
  encode gzip
  reverse_proxy gitea:3000
}
EOF

cat > /opt/gitea-smoke/docker-compose.yml <<EOF
services:
  gitea:
    image: $${IMAGE}
    container_name: gitea
    restart: unless-stopped
    environment:
      USER_UID: "1000"
      USER_GID: "1000"
      GITEA__server__DOMAIN: "$${SMOKE_HOST}"
      GITEA__server__ROOT_URL: "$${ROOT_URL}"
      GITEA__server__HTTP_PORT: "3000"
      GITEA__server__DISABLE_SSH: "true"
      GITEA__database__DB_TYPE: "sqlite3"
      GITEA__security__INSTALL_LOCK: "true"
      GITEA__service__DISABLE_REGISTRATION: "false"
    volumes:
      - /data/gitea:/data
    networks: [smoke]

  caddy:
    image: docker.io/library/caddy:2
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /opt/gitea-smoke/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    depends_on: [gitea]
    networks: [smoke]

networks:
  smoke:

volumes:
  caddy_data:
  caddy_config:
EOF

cd /opt/gitea-smoke
docker compose up -d
echo "smoke stack started: $${ROOT_URL}"
