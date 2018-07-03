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

module "swarm-cluster-managers" {
  source          = "../../"
  total_instances = 1
  domain          = "do.example.com"
  ssh_keys        = "${var.ssh_keys}"
  image           = "centos-7-x64"
  provision_user  = "root"
  user_data       = "${file("scripts/install-docker-ce.sh")}"
  tags            = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
}
