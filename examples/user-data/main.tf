variable "do_token" {}

variable "ssh_keys" {
  type = "list"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_tag" "cluster" {
  name = "cluster"
}

resource "digitalocean_tag" "manager" {
  name = "manager"
}

resource "digitalocean_tag" "worker" {
  name = "worker"
}

module "swarm-cluster" {
  source            = "../../"
  total_managers    = 1
  total_workers     = 1
  domain            = "do.example.com"
  do_token          = "${var.do_token}"
  manager_ssh_keys  = "${var.ssh_keys}"
  worker_ssh_keys   = "${var.ssh_keys}"
  manager_image     = "centos-7-x64"
  worker_image      = "centos-7-x64"
  provision_user    = "root"
  manager_user_data = "${file("scripts/install-docker-ce.sh")}"
  worker_user_data  = "${file("scripts/install-docker-ce.sh")}"
  manager_tags      = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
  worker_tags       = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.worker.id}"]
}
