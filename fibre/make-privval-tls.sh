#!/usr/bin/env bash
# Issue mutual-TLS certificates for the validator privval gRPC endpoint.
# Run on an admin workstation, not on a production server. Keep ca.key offline.
# Source: https://github.com/celestiaorg/celestia-core/blob/main/docs/guides/privval-grpc-tls.md
set -euo pipefail
VALIDATOR_IP="${1:?usage: $0 <validator_private_ip>}"
umask 077
mkdir -p privval-tls && cd privval-tls

openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes \
  -keyout ca.key -out ca.crt -days 3650 -subj "/CN=privval-ca"

openssl req -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes \
  -keyout server.key -out server.csr -subj "/CN=privval-server"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt -days 825 \
  -extfile <(printf "subjectAltName=IP:%s\nextendedKeyUsage=serverAuth" "$VALIDATOR_IP")

openssl req -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes \
  -keyout client.key -out client.csr -subj "/CN=privval-client"
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out client.crt -days 825 \
  -extfile <(printf "extendedKeyUsage=clientAuth")

rm -f server.csr client.csr
echo "validator: ca.crt server.crt server.key"
echo "fibre:     ca.crt client.crt client.key"
echo "offline:   ca.key"
