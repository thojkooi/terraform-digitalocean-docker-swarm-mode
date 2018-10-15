variable "do_token" {}

provider "digitalocean" {
  version = ""
  token   = "${var.do_token}"
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

resource "digitalocean_tag" "api" {
  name = "api-worker"
}

resource "digitalocean_tag" "web" {
  name = "web"
}

# Configure the Swarm mode firewall rules, allows for communication between cluster nodes on the private network but does not allow outside access
module "swarm-firewall" {
  source              = "github.com/thojkooi/terraform-digitalocean-docker-swarm-firewall"
  prefix              = "example-org"
  cluster_tags        = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
  cluster_droplet_ids = []

  # allowed_outbound_addresses = ["0.0.0.0/0"]
}

module "default-firewall" {
  source  = "thojkooi/firewall-rules/digitalocean"
  version = "1.0.0"
  prefix  = "example"
  tags    = ["${digitalocean_tag.cluster.id}"]
}

# Bootstrap the cluster, sets up generic workers and the managers
module "swarm-cluster" {
  source = "../../"

  # source           = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode"
  total_managers   = 1
  total_workers    = 0
  region           = "ams3"
  manager_ssh_keys = "${var.ssh_keys}"
  worker_ssh_keys  = "${var.ssh_keys}"
  domain           = "do.example.com"
  manager_tags     = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.manager.id}"]
}

# Add specific web nodes
module "web-nodes" {
  source = "../../modules/workers"

  # source             = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode/modules/workers"
  region             = "ams3"
  size               = "s-1vcpu-1gb"
  name               = "web"
  domain             = "do.example.com"
  total_instances    = 1
  manager_private_ip = "${element(module.swarm-cluster.manager_ips_private, 0)}"
  join_token         = "${module.swarm-cluster.worker_token}"
  ssh_keys           = "${var.ssh_keys}"
  tags               = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.web.id}"]
}

# Add specific backend nodes
module "backend-nodes" {
  source = "../../modules/workers"

  # source             = "github.com/thojkooi/terraform-digitalocean-docker-swarm-mode/modules/workers"
  region             = "ams3"
  size               = "s-1vcpu-1gb"
  name               = "api"
  domain             = "do.example.com"
  total_instances    = 1
  manager_private_ip = "${element(module.swarm-cluster.manager_ips_private, 0)}"
  join_token         = "${module.swarm-cluster.worker_token}"
  ssh_keys           = "${var.ssh_keys}"
  tags               = ["${digitalocean_tag.cluster.id}", "${digitalocean_tag.api.id}"]
}
