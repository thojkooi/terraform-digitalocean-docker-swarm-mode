# Terraform - DigitalOcean Docker Swarm mode workers

Terraform module to provision a Docker Swarm mode worker nodes to join a cluster using a private network on DigitalOcean.

[![CircleCI](https://circleci.com/gh/thojkooi/terraform-digitalocean-swarm-workers.svg?style=svg)](https://circleci.com/gh/thojkooi/terraform-digitalocean-swarm-workers)

- [Requirements](#requirements)
- [Usage](#usage)

## Requirements

- Terraform >= 0.11.7
- Digitalocean account / API token with write access
- SSH Keys added to your DigitalOcean account

## Usage

```hcl

module "workers" {
  source   = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode/tree/master/modules/workers"

  size            = "s-1vcpu-1gb"
  name            = "web"
  region          = "ams3"
  domain          = "example.com"
  total_instances = 3

  manager_private_ip = "${element(digitalocean_droplet.manager.*.ipv4_address_private, 0)}"
  join_token         = "${lookup(data.external.swarm_tokens.result, "worker")}"

  ssh_keys          = [1234, 1235, ...]
  provision_ssh_key = "~/.ssh/id_rsa"
  provision_user    = "core"
}

```

### SSH Key

Terraform uses an SSH key to connect to the created droplets in order to issue `docker swarm join` commands. By default this uses `~/.ssh/id_rsa`. If you wish to use a different key, you can modify this using the variable `provision_ssh_key`. You also need to ensure the public key is added to your DigitalOcean account and it's ID is listed in the `ssh_keys` list.
