#!/bin/bash

# Wait until Docker is running correctly
while [ -z "$(${docker_cmd} info | grep CPUs)" ]; do
  echo Waiting for Docker to start...
  sleep 2
done

# Join cluster
${docker_cmd} swarm join --token $1 \
  --availability ${availability} ${manager_private_ip}:2377
