#!/usr/bin/bash
ctr=$(buildah from ubuntu:24.04);
buildah run "$ctr" -- bash -c "echo 'Australia/Perth' > /etc/timezone"
buildah run "$ctr" -- apt update
buildah run "$ctr" -- apt install --assume-yes erlang-nox iproute2 make git build-essential curl erlang-dev
buildah add "$ctr" . /var/www/mtls_server
buildah commit "$ctr" "erlang-nox-mtls-ip-git"
