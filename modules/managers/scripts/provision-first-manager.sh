#!/bin/bash

MANAGER_PRIVATE_ADDR=$1

# Wait until Docker is running correctly
while [ -z "$(${docker_cmd} info | grep CPUs)" ]; do
  echo Waiting for Docker to start...
  sleep 2
done

${docker_cmd} swarm init --advertise-addr $MANAGER_PRIVATE_ADDR
