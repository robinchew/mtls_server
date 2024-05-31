#!/bin/bash
set -x
# Root Certificate

openssl ecparam -out root.key -name prime256v1 -genkey

openssl req -new -sha256 -key root.key -out root.csr -subj '/CN=root'

openssl x509 -req -sha256 -days 3650 -in root.csr -signkey root.key -out root.crt

# Server Certificate

openssl ecparam -out server.key -name prime256v1 -genkey

openssl req -new -sha256 -key server.key -out server.csr -subj '/C=AU/CN=localhost'

openssl x509 -req -in server.csr -CA  root.crt -CAkey root.key -CAcreateserial -out server.crt -days 365 -sha256

# Client Certificate

openssl ecparam -out client.key -name prime256v1 -genkey

openssl req -new -sha256 -key client.key -out client.csr -subj '/CN=client'

openssl x509 -req -in client.csr -CA  root.crt -CAkey root.key -CAcreateserial -out client.crt -days 365 -sha256

openssl pkcs12 -in client.crt -inkey client.key -out client.p12 -export -name App_Client
