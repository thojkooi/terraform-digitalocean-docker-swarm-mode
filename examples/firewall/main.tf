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
  source           = "thojkooi/docker-swarm-mode/digitalocean"
  total_managers   = 3
  total_workers    = 5
  version          = "0.1.1"
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
  source                     = "github.com/thojkooi/terraform-digitalocean-docker-swarm-firewall"
  do_token                   = "${var.do_token}"
  prefix                     = "example-com"
  cluster_tags               = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}", "${digitalocean_tag.worker.id}"]
  cluster_droplet_ids        = []
  allowed_outbound_addresses = ["0.0.0.0/0"]
}
