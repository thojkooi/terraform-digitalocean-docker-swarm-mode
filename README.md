# Terraform DigitalOcean Docker Swarm mode

Terraform module to provision a Docker Swarm mode cluster in a single availability zone on DigitalOcean, using a private network.

By default using the CoreOS alpha image provided by DigitalOcean, but supports expandable configuration to support installation and configuration of e.g. puppet or other configuration management tooling or manual installation of Docker through other means.

- [Requirements](#requirements)
- [Usage](#usage)
- [Examples](#examples)
- [Swarm set-up](#swarm set-up)

## Requirements

- Terraform >= 0.10.6
- Digitalocean account / API token with write access
- SSH Keys added to your DigitalOcean account
- [jq](https://github.com/stedolan/jq)

## Usage

```hcl
module "swarm-cluster" {
  source           = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode"
  domain           = "do.example.com"
  total_managers   = 3
  total_workers    = 2
  do_token         = "${var.do_token}"
  manager_ssh_keys = [1234, 1235, ...]
  worker_ssh_keys  = [1234, 1235, ...]
}
```

### SSH Key

Terraform uses an SSH key to connect to the created droplets in order to issue `docker swarm join` commands. By default this uses `~/.ssh/id_rsa`. If you wish to use a different key, you can modify this using the variable `provision_ssh_key`. You also need to ensure the public key is added to your DigitalOcean account and it's ID is listed in both the `manager_ssh_keys` and `worker_ssh_keys` lists.

### Notes

This module does not set up a firewall or modifies any other security settings. Please configure this by providing user data for the manager and worker nodes. Also set up firewall rules on DigitalOcean for the cluster, to ensure only cluster members can access the internal Swarm ports.

## Examples

For examples, see the [examples directory](https://github.com/thojkooi/terraform-digitalocean-docker-swarm-mode/tree/master/examples).

### Using user data

You can use user_data to manually install Docker on other OS images or use it to install configuration management tooling such as Puppet.

```hcl
module "swarm-cluster" {
    source            = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode"
    total_managers    = 1
    total_workers     = 1
    domain            = "do.example.com"
    do_token          = "${var.do_token}"
    manager_ssh_keys  = "${var.ssh_keys}"
    worker_ssh_keys   = "${var.ssh_keys}"
    manager_os        = "centos-7-x64"
    worker_os         = "centos-7-x64"
    provision_user    = "root"
    manager_user_data = "${file("scripts/install-docker-ce.sh")}"
    worker_user_data  = "${file("scripts/install-docker-ce.sh")}"
    manager_tags      = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
    worker_tags       = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.worker.id}"]
}

```

### Extra nodes

```hc1

module "swarm-cluster" {
    source           = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode"
    total_managers   = 1
    total_workers    = 0
    region           = "ams3"
    do_token         = "${var.do_token}"
    manager_ssh_keys = "${var.ssh_keys}"
    worker_ssh_keys  = "${var.ssh_keys}"
    domain           = "do.example.com"
}

resource "digitalocean_droplet" "worker" {
    ssh_keys           = "${var.ssh_keys}"
    image              = "coreos-alpha"
    region             = "ams3"
    size               = "512mb"
    private_networking = true
    backups            = false
    ipv6               = false
    name               = "custom-node"
    depends_on         = ["module.swarm-cluster"]

    connection {
        type        = "ssh"
        user        = "core"
        private_key = "${file("~/.ssh/id_rsa")}"
        timeout     = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo docker swarm join --token ${module.swarm-cluster.worker_token} ${module.swarm-cluster.manager_ips_private[0]}:2377"
        ]
    }

}
```

## Swarm set-up

### Manager nodes

First a single Swarm mode manager is provisioned. This is the leader node. If you have additional manager nodes, these will be provisioned after this step. Once the manager nodes have been provisioned, Terraform will initialize the Swarm on the first manager node and retrieve the join tokens. It will then have all the managers join the cluster.

If the cluster is already up and running, Terraform will check with the first leader node to refresh the join tokens. It will join any additional manager nodes that are provisioned automagically to the Swarm.

#### Worker nodes

Worker nodes should be used to run the Docker Swarm mode Services. By default, 2 worker nodes are provisioned. Set the number of desired worker nodes using the following variable: `total_workers`
