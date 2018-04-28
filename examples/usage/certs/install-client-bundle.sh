#!/bin/bash

echo Using for remote API host name: $1

echo Installing client bundle...
mkdir .docker
cp ca.pem .docker/ca.pem
cp client.pem .docker/cert.pem
cp client-key.pem .docker/key.pem

echo Configuring Docker client to talk to remote API...
export DOCKER_CERT_PATH=$(pwd)/.docker
export DOCKER_HOST=tcp://$1:2376 DOCKER_TLS_VERIFY=1
