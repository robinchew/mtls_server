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

openssl ecparam -out root.key -name prime256v1 -genkey

openssl req -new -sha256 -key root.key -out root.csr -subj '/CN=rootCN'

openssl x509 -req -sha256 -days 3650 -in root.csr -signkey root.key -out root.crt

# Server Certificate

openssl ecparam -out server.key -name prime256v1 -genkey

openssl req -new -sha256 -key server.key -out server.csr -subj '/C=AU/CN=localhostCN'

openssl x509 -req -in server.csr -CA  root.crt -CAkey root.key -CAcreateserial -out server.crt -days 1 -sha256

# Client Certificate

openssl ecparam -out client.key -name prime256v1 -genkey

openssl req -new -sha256 -key client.key -out client.csr -subj '/CN=clientCN'

openssl x509 -req -in client.csr -CA  root.crt -CAkey root.key -CAcreateserial -out client.crt -days 1 -sha256

openssl pkcs12 -in client.crt -inkey client.key -out client.p12 -export -name App_Client
