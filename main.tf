provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "manager" {
    ssh_keys           = "${var.manager_ssh_keys}"
    image              = "${var.manager_os}"
    region             = "${var.region}"
    size               = "${var.manager_size}"
    private_networking = true
    backups            = false
    ipv6               = false
    tags               = ["${var.manager_tags}"]
    user_data          = "${var.manager_user_data}"
    count              = "${var.total_managers}"
    name               = "${format("%s-%02d.%s.%s", var.manager_name, count.index + 1, var.region, var.domain)}"

    connection {
        type     = "ssh"
        user     = "${var.provision_user}"
        private_key = "${file("${var.provision_ssh_key}")}"
        timeout  = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            "while [ ! $(docker info) ]; do sleep 2; done",
            # TODO: Handle failure during swarm init, only run this if manager node is not in a swarm
            "if [ ${count.index} -eq 0 ]; then sudo docker swarm init --advertise-addr ${digitalocean_droplet.manager.0.ipv4_address_private}; exit 0; fi"
        ]
    }
}

data "external" "swarm_tokens" {
    program = ["bash", "${path.module}/scripts/get-swarm-join-tokens.sh"]
    query = {
        host = "${digitalocean_droplet.manager.0.ipv4_address}"
        user = "${var.provision_user}"
        private_key = "${var.provision_ssh_key}"
    }
    depends_on = ["digitalocean_droplet.manager"]
}

#
resource "null_resource" "bootstrap" {
    depends_on = ["data.external.swarm_tokens"]
    count       = "${var.total_managers}"

    triggers {
        cluster_instance_ids = "${join(",", digitalocean_droplet.manager.*.id)}"
    }

    connection {
        host = "${element(digitalocean_droplet.manager.*.ipv4_address, count.index)}"
        type     = "ssh"
        user     = "${var.provision_user}"
        private_key = "${file("${var.provision_ssh_key}")}"
        timeout  = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            "while [ ! $(docker info) ]; do sleep 2; done",
            "if [ ${count.index} -gt 0 ] && [! sudo docker info | grep -q \"Swarm: active\" ]; then sudo docker swarm join --token ${data.external.swarm_tokens.result.manager} ${digitalocean_droplet.manager.0.ipv4_address_private}:2377; exit 0; fi"
        ]
    }
}

resource "digitalocean_droplet" "worker" {
    ssh_keys           = "${var.worker_ssh_keys}"
    image              = "${var.worker_os}"
    region             = "${var.region}"
    size               = "${var.worker_size}"
    private_networking = true
    backups            = false
    ipv6               = false
    user_data          = "${var.worker_user_data}"
    tags               = ["${var.worker_tags}"]
    count              = "${var.total_workers}"
    name               = "${format("%s-%02d.%s.%s", var.worker_name, count.index + 1, var.region, var.domain)}"
    depends_on         = ["digitalocean_droplet.manager"]

    connection {
        type        = "ssh"
        user        = "${var.provision_user}"
        private_key = "${file("${var.provision_ssh_key}")}"
        timeout     = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            "while [ ! $(docker info) ]; do sleep 2; done",
            "sudo docker swarm join --token ${data.external.swarm_tokens.result.worker} ${digitalocean_droplet.manager.0.ipv4_address_private}:2377"
        ]
    }

    # Handle clean up / destroy worker node
    # drain worker on destroy
    provisioner "remote-exec" {
      when = "destroy"

      inline = [
        "docker node update --availability drain ${self.name}",
      ]

      on_failure = "continue"
      # TODO: Handle downed manger node, move to a different node to drain worker node
      connection {
        type        = "ssh"
        user        = "${var.provision_user}"
        private_key = "${file("${var.provision_ssh_key}")}"
        host        = "${digitalocean_droplet.manager.0.ipv4_address}"
      }
    }

    # leave swarm on destroy
    provisioner "remote-exec" {
      when = "destroy"

      inline = [
        "docker swarm leave",
      ]

      on_failure = "continue"
    }

    # remove node on destroy
    provisioner "remote-exec" {
      when = "destroy"

      inline = [
        "docker node rm --force ${self.name}",
      ]

      on_failure = "continue"

      connection {
          type        = "ssh"
          user        = "${var.provision_user}"
          private_key = "${file("${var.provision_ssh_key}")}"
          host        = "${digitalocean_droplet.manager.0.ipv4_address}"
      }
    }

}
