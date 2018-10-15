variable "do_token" {}

variable "ssh_keys" {
  type = "list"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_tag" "manager" {
  name = "swarm-mode-manager"
}

module "managers" {
  source = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode//modules/managers"

  domain          = "do.example.com"
  total_instances = 3
  ssh_keys        = ["${var.ssh_keys}"]

  remote_api_ca          = "${path.module}/ca.pem"
  remote_api_certificate = "${path.module}/server.pem"
  remote_api_key         = "${path.module}/server-key.pem"

  size = "s-2vcpu-4gb"

  tags = ["${digitalocean_tag.manager.id}"]

  providers = {}
}

module "basic-fw-rules" {
  source  = "thojkooi/firewall-rules/digitalocean"
  version = "1.0.0"

  prefix = "do-example-com"
  tags   = ["${digitalocean_tag.manager.id}"]
}

module "api-access-firewall" {
  source                   = "github.com/thojkooi/terraform-digitalocean-firewall-docker-api?ref=v0.1.2"
  prefix                   = "do-example-com"
  tags                     = ["${digitalocean_tag.manager.id}"]
  api_access_from_adresses = ["0.0.0.0/0", "::/0"]
}

module "swarm-mode-firewall" {
  source  = "thojkooi/docker-swarm-firewall/digitalocean"
  version = "1.0.0"

  prefix              = "do-example-com"
  cluster_droplet_ids = []
  cluster_tags        = ["${digitalocean_tag.manager.id}"]
}
