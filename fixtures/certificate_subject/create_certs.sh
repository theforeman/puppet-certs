#!/bin/bash

CERTS_DIR=certs

mkdir -p certs

CA_CERT_NAME=ca
if [[ ! -f "$CERTS_DIR/$CA_CERT_NAME.key" || ! -f "$CERTS_DIR/$CA_CERT_NAME.crt" ]]; then
  echo "Generate CA"
  openssl genrsa -out $CERTS_DIR/$CA_CERT_NAME.key 2048
  openssl req -x509 -new -nodes -key $CERTS_DIR/$CA_CERT_NAME.key -sha256 -days 3650 -out $CERTS_DIR/$CA_CERT_NAME.crt -subj "/CN=Test Self-Signed CA"
else
  echo "CA certificate exists. Skipping."
fi

CERT_NAME=server
if [[ ! -f "$CERTS_DIR/$CERT_NAME.key" || ! -f "$CERTS_DIR/$CERT_NAME.crt" ]]; then
  echo "Generate server certificate"
  openssl genrsa -out $CERTS_DIR/$CERT_NAME.key 2048
  openssl req -new -key $CERTS_DIR/$CERT_NAME.key -out $CERTS_DIR/$CERT_NAME.csr -subj "/C=US/O=Test Org/CN=foreman.example.com"
  openssl x509 -req -in $CERTS_DIR/$CERT_NAME.csr -CA $CERTS_DIR/$CA_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CERT_NAME.crt -days 3650 -sha256
else
  echo "Server certificate exists. Skipping."
fi

rm -rf $CERTS_DIR/*.{srl,csr}
