#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <client-hostname>"
    exit 1
fi

set -e

echo " :: Creating the client key and CSR."
openssl genrsa -out dash-client-$1.key 2048
CERT_CN=$1 openssl req -new -key dash-client-$1.key \
    -config openssl.cert.cnf -out dash-client-$1.csr

echo " :: Signing the client certificate."
echo "    Use the password you entered when creating the root CA."
openssl x509 -req -in dash-client-$1.csr \
    -CA dash-rootca.crt -CAkey dash-rootca.key \
    -extfile openssl.rootca.cnf  -extensions dash_client \
    -out dash-client-$1.crt
