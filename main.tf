module "managers" {
  source   = "github.com/thojkooi/terraform-digitalocean-swarm-managers"
  do_token = "${var.do_token}"

  image  = "${var.manager_image}"
  size   = "${var.manager_size}"
  name   = "${var.manager_name}"
  region = "${var.region}"
  domain = "${var.domain}"

  total_instances = "${var.total_managers + 1}"
  user_data       = "${var.manager_user_data}"
  tags            = "${var.manager_tags}"

  ssh_keys          = "${var.worker_ssh_keys}"
  provision_ssh_key = "${var.provision_ssh_key}"
  provision_user    = "${var.provision_user}"
}

module "workers" {
  source   = "github.com/thojkooi/terraform-digitalocean-swarm-workers"
  do_token = "${var.do_token}"

  image  = "${var.worker_image}"
  size   = "${var.worker_size}"
  name   = "${var.worker_name}"
  region = "${var.region}"
  domain = "${var.domain}"

  total_instances = "${var.total_workers}"
  user_data       = "${var.worker_user_data}"
  tags            = "${var.worker_tags}"

  manager_public_ip  = "${element(module.managers.ipv4_addresses, 0)}"
  manager_private_ip = "${element(module.managers.ipv4_addresses_private, 0)}"
  join_token         = "${module.managers.worker_token}"

  ssh_keys          = "${var.worker_ssh_keys}"
  provision_ssh_key = "${var.provision_ssh_key}"
  provision_user    = "${var.provision_user}"
}
