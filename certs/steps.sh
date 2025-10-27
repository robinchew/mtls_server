#!/bin/bash
set -x

suffix=`date +%Y-%m-%d_%H:%M`
domain=${1:-localhost}
root=${2:-root_$suffix}
server=server_$suffix
client=client_$suffix

# Root Certificate

if [ ! -f $root.key ] || [ ! -f $root.csr ] || [ ! -f $root.crt ]; then
    openssl ecparam -out $root.key -name prime256v1 -genkey
    openssl req -new -sha256 -key $root.key -out $root.csr -subj '/CN=FileSaverRootCN'
    openssl x509 -req -sha256 -days 3650 -in $root.csr -signkey $root.key -out $root.crt
fi

# Server Certificate

openssl ecparam -out $server.key -name prime256v1 -genkey

#openssl req -new -sha256 -key $server.key -out $server.csr -subj '/C=AU/CN=FileSaverServerCN'
openssl req -new -sha256 -key $server.key -out $server.csr -subj '/CN=FileSaverServer' \
    #-reqexts SAN \
    #-config <(cat /etc/ssl/openssl.cnf \
    #    <(printf "\n[SAN]\nsubjectAltName=DNS:localhost"))
    -addext "subjectAltName = DNS:$domain"
    #-addext "certificatePolicies = 1.2.3.4"

#openssl x509 -req -in $server.csr -CA  $root.crt -CAkey $root.key -CAcreateserial -out $server.crt -days 1 -sha256

cnf_file=$(mktemp --suffix .cnf)

cat > $cnf_file <<EOF
[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $domain

[ ca ]
default_ca  = CA_default

[ CA_default ]
database = ca_default_db.txt
default_md	= default		# use public key default MD
EOF

openssl x509 -req -in $server.csr -CA  $root.crt -CAkey $root.key -CAcreateserial -out $server.crt -days 1 -sha256 \
    -extensions v3_req -extfile $cnf_file # no -addext equivalent for openssl x509, so use -extfile instead

rm $cnf_file

# Client Certificate

openssl ecparam -out $client.key -name prime256v1 -genkey

openssl req -new -sha256 -key $client.key -out $client.csr -subj '/CN=FileSaverClient'

#openssl x509 -req -in $client.csr -CA  $root.crt -CAkey $root.key -CAcreateserial -out $client.crt -days 1 -sha256

openssl x509 -req -in $client.csr -CA  $root.crt -CAkey $root.key -CAcreateserial -out $client.crt -days 1 -sha256

openssl pkcs12 -in $client.crt -inkey $client.key -out $client.p12 -export -name App_Client
