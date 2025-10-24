#!/bin/bash
set -x

start=`python << EOF
from datetime import datetime, timedelta

print(datetime.now().strftime('%Y%m%d%H%M%S'))

import time

# Get the current time in seconds since the epoch
epoch_time = time.time()
start = int(epoch_time)
#print(start)
#print('{}Z'.format(start, start + (3 * 60)))
EOF`;

# end=$(($start + 180))

end=`python << EOF
from datetime import datetime, timedelta

print((datetime.now() + timedelta(minutes=3)).strftime('%Y%m%d%H%M%S'))
EOF`;

# Root Certificate

if [ ! -f root.key ] || [ ! -f root.csr ] || [ ! -f root.crt ]; then
    openssl ecparam -out root.key -name prime256v1 -genkey
    openssl req -new -sha256 -key root.key -out root.csr -subj '/CN=FileSaverRootCN'
    openssl x509 -req -sha256 -days 3650 -in root.csr -signkey root.key -out root.crt
fi

# Server Certificate

openssl ecparam -out server.key -name prime256v1 -genkey

#openssl req -new -sha256 -key server.key -out server.csr -subj '/C=AU/CN=FileSaverServerCN'
openssl req -new -sha256 -key server.key -out server.csr -subj '/CN=FileSaverServer' \
    #-reqexts SAN \
    #-config <(cat /etc/ssl/openssl.cnf \
    #    <(printf "\n[SAN]\nsubjectAltName=DNS:localhost"))
    -addext 'subjectAltName = DNS:localhost'
    #-addext "certificatePolicies = 1.2.3.4"

#openssl x509 -req -in server.csr -CA  root.crt -CAkey root.key -CAcreateserial -out server.crt -days 1 -sha256

openssl x509 -req -in server.csr -CA  root.crt -CAkey root.key -CAcreateserial -out server.crt -days 1 -sha256 \
    -extensions v3_req -extfile localhost_cert.cnf # no -addext equivalent for openssl x509, so use -extfile instead

# Client Certificate

openssl ecparam -out client.key -name prime256v1 -genkey

openssl req -new -sha256 -key client.key -out client.csr -subj '/CN=FileSaverClient'
    #-reqexts SAN \
    #-config <(cat /etc/ssl/openssl.cnf \
    #    <(printf "\n[SAN]\nsubjectAltName=DNS:localhost"))
    #-addext 'subjectAltName = DNS:localhost'
    #-addext "certificatePolicies = 1.2.3.4"

#openssl x509 -req -in client.csr -CA  root.crt -CAkey root.key -CAcreateserial -out client.crt -days 1 -sha256

openssl x509 -req -in client.csr -CA  root.crt -CAkey root.key -CAcreateserial -out client.crt -days 1 -sha256

openssl pkcs12 -in client.crt -inkey client.key -out client.p12 -export -name App_Client
