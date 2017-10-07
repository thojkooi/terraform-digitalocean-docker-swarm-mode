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

module "swarm-firewall" {
  source                     = "github.com/thojkooi/terraform-digitalocean-swarm-firewall"
  do_token                   = "${var.do_token}"
  prefix                     = "example-com"
  cluster_tags               = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}", "${digitalocean_tag.worker.id}"]
  cluster_droplet_ids        = []
  allowed_outbound_addresses = ["0.0.0.0/0", "::/0"]
}

module "swarm-cluster" {
  source           = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode"
  total_managers   = 3
  total_workers    = 5
  region           = "ams3"
  do_token         = "${var.do_token}"
  manager_ssh_keys = "${var.ssh_keys}"
  worker_ssh_keys  = "${var.ssh_keys}"
  manager_tags     = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
  worker_tags      = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.worker.id}"]
  domain           = "do.example.com"
}
