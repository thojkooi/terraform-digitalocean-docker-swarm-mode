# Terraform - DigitalOcean Docker Swarm mode managers

Terraform module to provision and bootstrap a Docker Swarm mode cluster with multiple managers using a private network on DigitalOcean.

- [Requirements](#requirements)
- [Usage](#usage)
- [Examples](#examples)

## Requirements

- Terraform >= 0.11.7
- Digitalocean account / API token with write access
- SSH Keys added to your DigitalOcean account
- [jq](https://github.com/stedolan/jq)

## Usage

```hcl
module "swarm-cluster" {
  source          = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode//modules/managers"
  domain          = "do.example.com"
  total_instances = 3
  ssh_keys        = [1234, 1235, ...]
  providers {}
}
```

### SSH Key

Terraform uses an SSH key to connect to the created droplets in order to issue `docker swarm join` commands. By default this uses `~/.ssh/id_rsa`. If you wish to use a different key, you can modify this using the variable `provision_ssh_key`. You also need to ensure the public key is added to your DigitalOcean account and it's ID is listed in the `ssh_keys` list.

### Exposing the Docker API

You can expose the Docker API to interact with the cluster remotely. This is done by providing a certificate and private key. See the [Docker TLS example](https://github.com/thojkooi/terraform-digitalocean-docker-swarm-mode/tree/master/modules/managers/tree/master/examples/remote-api-tls).

```hcl
module "swarm_mode_cluster" {
  source          = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode//modules/managers"

  domain          = "do.example.com"
  total_instances = 3
  ssh_keys        = [1234, 1235, ...]

  remote_api_ca          = "${path.module}/certs/ca.pem"
  remote_api_certificate  = "${path.module}/certs/server.pem"
  remote_api_key         = "${path.module}/certs/server-key.pem"

  size = "s-2vcpu-4gb"

  tags = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]

  providers = {}
}
```

### Notes

This module does not set up a firewall or modifies any other security settings. Please configure this by providing user data for the manager nodes. Also set up firewall rules on DigitalOcean for the cluster, to ensure only cluster members can access the internal Swarm ports.

## Examples

For examples, see the [examples directory](https://github.com/thojkooi/terraform-digitalocean-docker-swarm-mode/tree/master/modules/managers/tree/master/examples).

## Swarm set-up

First a single Swarm mode manager is provisioned. This is the leader node. If you have additional manager nodes, these will be provisioned after this step. Once the manager nodes have been provisioned, Terraform will initialize the Swarm on the first manager node and retrieve the join tokens. It will then have all the managers join the cluster.

If the cluster is already up and running, Terraform will check with the first leader node to refresh the join tokens. It will join any additional manager nodes that are provisioned automagically to the Swarm.
