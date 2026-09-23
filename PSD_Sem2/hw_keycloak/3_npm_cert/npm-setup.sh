#!/usr/bin/env bash
# Автоматизация шагов из UI NPM (можно сделать и руками, см. README):
#   1. SSL Certificates → Add → Custom: загрузить certs/server.crt + certs/server.key
#   2. Proxy Hosts → Add: DOMAIN → http://keycloak:8080, SSL: этот сертификат, Force SSL
# Требует: запущенные npm/ и keycloak/, выпущенные certs/, заполненные .env.
set -euo pipefail
cd "$(dirname "$0")"

set -a; source npm/.env; source keycloak/.env; set +a
DOMAIN="${DOMAIN:-keycloak.localhost}"
API="http://127.0.0.1:81/api"

json() { python3 -c "import json,sys; print(json.load(sys.stdin)$1)"; }

TOKEN=$(curl -sf -H 'Content-Type: application/json' \
  -d "{\"identity\":\"${NPM_ADMIN_EMAIL}\",\"secret\":\"${NPM_ADMIN_PASSWORD}\"}" \
  "$API/tokens" | json "['token']")
AUTH=(-H "Authorization: Bearer ${TOKEN}")

echo "→ Загружаем самоподписанный сертификат"
CERT_ID=$(curl -sf "${AUTH[@]}" -H 'Content-Type: application/json' \
  -d "{\"provider\":\"other\",\"nice_name\":\"${DOMAIN} (MyCloudCA)\"}" \
  "$API/nginx/certificates" | json "['id']")
curl -sf "${AUTH[@]}" \
  -F "certificate=@certs/server.crt" \
  -F "certificate_key=@certs/server.key" \
  "$API/nginx/certificates/${CERT_ID}/upload" > /dev/null

echo "→ Создаём Proxy Host ${DOMAIN} → keycloak:8080"
# Keycloak отдаёт большие заголовки (cookies/токены) — увеличиваем буферы nginx
ADVANCED='proxy_buffer_size 128k;\nproxy_buffers 4 256k;\nproxy_busy_buffers_size 256k;'
curl -sf "${AUTH[@]}" -H 'Content-Type: application/json' -d "{
  \"domain_names\": [\"${DOMAIN}\"],
  \"forward_scheme\": \"http\",
  \"forward_host\": \"keycloak\",
  \"forward_port\": 8080,
  \"certificate_id\": ${CERT_ID},
  \"ssl_forced\": true,
  \"http2_support\": true,
  \"hsts_enabled\": false,
  \"block_exploits\": true,
  \"allow_websocket_upgrade\": true,
  \"caching_enabled\": false,
  \"access_list_id\": 0,
  \"advanced_config\": \"${ADVANCED}\",
  \"meta\": {},
  \"locations\": []
}" "$API/nginx/proxy-hosts" > /dev/null

echo "Готово: https://${DOMAIN}"
