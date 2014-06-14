#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <server-hostname>"
    exit 1
fi

set -e

echo " :: Creating the root CA key and certificate."
echo "    The password you pick will be required for generating new client certificates."
openssl req -newkey rsa -x509 -days 3650 -config openssl.rootca.cnf -out dash-rootca.crt
echo 000a > dash-rootca.srl

echo " :: Creating the server key and CSR."
openssl genrsa -out dash-server.key 2048
CERT_CN=$1 openssl req -new -key dash-server.key \
    -config openssl.cert.cnf -out dash-server.csr

echo " :: Signing the server certificate. Use the password you entered above."
openssl x509 -req -in dash-server.csr -days 3650 \
    -CA dash-rootca.crt -CAkey dash-rootca.key \
    -extfile openssl.rootca.cnf -extensions dash_server \
    -out dash-server.crt
