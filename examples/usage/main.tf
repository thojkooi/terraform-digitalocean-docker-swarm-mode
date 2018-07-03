variable "do_token" {}

variable "ssh_keys" {
  type = "list"
}

provider "digitalocean" {
  token = "${var.do_token}"
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

module "swarm_mode_cluster" {
  source = "../../"

  total_managers = 3
  total_workers  = 1
  region         = "ams3"
  domain         = "swarm.containerinfra.com"

  manager_ssh_keys = "${var.ssh_keys}"
  worker_ssh_keys  = "${var.ssh_keys}"

  remote_api_ca          = "${path.module}/certs/ca.pem"
  remote_api_certificate = "${path.module}/certs/server.pem"
  remote_api_key         = "${path.module}/certs/server-key.pem"

  manager_size = "s-2vcpu-4gb"
  worker_size  = "s-1vcpu-1gb"
  manager_tags = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
  worker_tags  = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.worker.id}"]
  providers    = {}
}

# Load balancer
resource "digitalocean_loadbalancer" "manager_api_access" {
  name   = "docker-swarm-api.ams3.prd.containerinfra.com"
  region = "ams3"

  forwarding_rule {
    entry_port     = 2376
    entry_protocol = "tcp"

    target_port     = 2376
    target_protocol = "tcp"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"

    check_interval_seconds   = 5
    response_timeout_seconds = 3
    unhealthy_threshold      = 5
    healthy_threshold        = 3
  }

  droplet_tag = "${digitalocean_tag.manager.id}"
}

# Firewall rules
module "basic-fw-rules" {
  source  = "thojkooi/firewall-rules/digitalocean"
  version = "1.0.0"

  prefix = "do-example-com"
  tags   = ["${digitalocean_tag.cluster.id}"]
}

module "api-access-firewall" {
  source                        = "github.com/thojkooi/terraform-digitalocean-firewall-docker-api?ref=v0.1.2"
  prefix                        = "do-example-com"
  tags                          = ["${digitalocean_tag.manager.id}"]
  api_access_from_adresses      = []
  api_access_load_balancer_uids = ["${digitalocean_loadbalancer.manager_api_access.id}"]
}

module "swarm-mode-firewall" {
  source  = "thojkooi/docker-swarm-firewall/digitalocean"
  version = "1.0.0"

  prefix              = "do-example-com"
  cluster_droplet_ids = []
  cluster_tags        = ["${digitalocean_tag.cluster.id}"]
}

resource "digitalocean_firewall" "http" {
  name = "do-example-com-http-access-fw"
  tags = ["${digitalocean_tag.cluster.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

output "manager_api_access" {
  value = "${digitalocean_loadbalancer.manager_api_access.ip}"
}
