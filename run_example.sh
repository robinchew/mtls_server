HERE=$(readlink -f `dirname $0`)

ROOT_CA_CERT=$HERE/certs/root_2025-41-27_23\:41.crt SERVER_CERT=$HERE/certs/server_2025-10-28_00\:02.crt SERVER_KEY=$HERE/certs/server_2025-10-28_00\:02.key make run
