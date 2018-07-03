#!/bin/bash

# Install certificates for the Docker Remote API
# Based on:
# - https://coreos.com/os/docs/latest/customizing-docker.html
# - https://docs.docker.com/engine/reference/commandline/dockerd/
# -https://docs.docker.com/engine/security/https/#secure-by-default

sudo systemctl stop docker
sudo systemctl disable docker

sudo mkdir -p /var/ssl
sudo mv ~/.docker/{server-cert.pem,server-key.pem,ca.pem} /var/ssl/

sudo cat<<-EOF > /etc/systemd/system/docker-tls-tcp.socket
[Unit]
Description=Docker Secured Socket for the API

[Socket]
ListenStream=2376
BindIPv6Only=both
Service=docker.service

[Install]
WantedBy=sockets.target
EOF

sudo systemctl enable docker-tls-tcp.socket
sudo systemctl stop docker
sudo systemctl start docker-tls-tcp.socket

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo cat<<-EOF > /etc/systemd/system/docker.service.d/10-tls-verify.conf
[Service]
Environment="DOCKER_OPTS=--tlsverify=true --tlscacert=/var/ssl/ca.pem --tlscert=/var/ssl/server-cert.pem --tlskey=/var/ssl/server-key.pem"
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker.service
