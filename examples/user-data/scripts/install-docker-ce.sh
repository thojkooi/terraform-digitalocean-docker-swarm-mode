#!/bin/bash

# Install requirements for Docker
yum -y update
yum install -y yum-utils device-mapper-persistent-data lvm2

# Add docker-ce repository and enable docker-ce-edge
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
yum -y makecache fast

# Install and enable docker
yum -y install docker-ce

sleep 1;

systemctl start docker
