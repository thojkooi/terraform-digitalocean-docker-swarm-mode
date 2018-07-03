#!/bin/bash

MANAGER_PRIVATE_ADDR=$1
JOIN_TOKEN=$2

# Wait until Docker is running correctly
while [ -z "$(${docker_cmd} info | grep CPUs)" ]; do
  echo Waiting for Docker to start...
  sleep 2
done

# Check if we are not already joined into a Swarm
if [ -z "$(${docker_cmd} info | grep 'Swarm: active')" ]; then
  # Join cluster
  ${docker_cmd} swarm join --token $JOIN_TOKEN $MANAGER_PRIVATE_ADDR:2377;
fi
