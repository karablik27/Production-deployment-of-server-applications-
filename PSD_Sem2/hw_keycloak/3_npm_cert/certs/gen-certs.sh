#!/usr/bin/env bash
# Выпуск собственного центра сертификации и серверного сертификата для Keycloak.
# Команды как на слайде «Создаем центр сертификации», но расширения передаются
# через -extfile: так работает и OpenSSL, и LibreSSL в macOS (там нет -copy_extensions).
# Использование: ./gen-certs.sh [домен]   (по умолчанию keycloak.localhost)
set -euo pipefail

DOMAIN="${1:-keycloak.localhost}"
cd "$(dirname "$0")"

# Центр сертификации (выпускаем один раз, повторно не перезаписываем)
if [[ ! -f ca.key ]]; then
  openssl genrsa -out ca.key 2048
  openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt \
    -subj "/CN=MyCloudCA"
fi

# Серверный сертификат
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=${DOMAIN}/O=CMTLab"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt -days 365 -sha256 \
  -extfile <(printf '%s\n' \
    "subjectAltName=DNS:${DOMAIN}" \
    "basicConstraints=CA:FALSE" \
    "keyUsage=digitalSignature,keyEncipherment" \
    "extendedKeyUsage=serverAuth")

rm -f server.csr
chmod 600 ca.key server.key

openssl x509 -in server.crt -noout -subject -issuer -dates
openssl verify -CAfile ca.crt server.crt
