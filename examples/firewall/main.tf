variable "do_token" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

variable "ssh_keys" {
  type = "list"
}

resource "digitalocean_tag" "cluster" {
  name = "swarm-mode-cluster"
}

resource "digitalocean_tag" "manager" {
  name = "manager"
}

resource "digitalocean_tag" "worker" {
  name = "worker"
}

module "swarm-cluster" {
  # source           = "thojkooi/docker-swarm-mode/digitalocean"
  source = "../../"

  # version          = "0.2.0"
  total_managers   = 3
  total_workers    = 5
  version          = "0.2.0"
  region           = "ams3"
  manager_ssh_keys = "${var.ssh_keys}"
  worker_ssh_keys  = "${var.ssh_keys}"
  manager_size     = "s-1vcpu-1gb"
  worker_size      = "s-1vcpu-1gb"
  manager_tags     = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
  worker_tags      = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.worker.id}"]
  domain           = "do.example.com"
}

module "swarm-firewall" {
  source              = "thojkooi/docker-swarm-firewall/digitalocean"
  version             = "1.0.0"
  prefix              = "example-com"
  cluster_tags        = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}", "${digitalocean_tag.worker.id}"]
  cluster_droplet_ids = []
}

module "default-firewall" {
  source  = "thojkooi/firewall-rules/digitalocean"
  version = "1.0.0"
  prefix  = "example"
  tags    = ["${digitalocean_tag.cluster.id}"]
}
