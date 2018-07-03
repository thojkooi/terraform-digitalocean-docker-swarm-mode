variable "do_token" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

variable "ssh_keys" {
  type = "list"
}

module "swarm-cluster" {
  source           = "thojkooi/docker-swarm-mode/digitalocean"
  version          = "0.1.0"
  total_managers   = 1
  total_workers    = 0
  region           = "ams3"
  manager_ssh_keys = "${var.ssh_keys}"
  worker_ssh_keys  = "${var.ssh_keys}"
  domain           = "do.example.com"
}

resource "digitalocean_droplet" "worker" {
  ssh_keys           = "${var.ssh_keys}"
  image              = "coreos-alpha"
  region             = "ams3"
  size               = "s-1vcpu-1gb"
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
      "sudo docker swarm join --token ${module.swarm-cluster.worker_token} ${module.swarm-cluster.manager_ips_private[0]}:2377",
    ]
  }
}
