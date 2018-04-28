module "managers" {
  source = "github.com/thojkooi/terraform-digitalocean-swarm-managers?ref=v0.2.0"

  image  = "${var.manager_image}"
  size   = "${var.manager_size}"
  name   = "${var.manager_name}"
  region = "${var.region}"
  domain = "${var.domain}"

  total_instances = "${var.total_managers}"
  user_data       = "${var.manager_user_data}"
  tags            = "${var.manager_tags}"

  remote_api_ca          = "${var.remote_api_ca}"
  remote_api_key         = "${var.remote_api_key}"
  remote_api_certificate = "${var.remote_api_certificate}"

  ssh_keys          = "${var.worker_ssh_keys}"
  provision_ssh_key = "${var.provision_ssh_key}"
  provision_user    = "${var.provision_user}"
}

module "workers" {
  source = "github.com/thojkooi/terraform-digitalocean-swarm-workers?ref=v0.3.0"

  image  = "${var.worker_image}"
  size   = "${var.worker_size}"
  name   = "${var.worker_name}"
  region = "${var.region}"
  domain = "${var.domain}"

  total_instances = "${var.total_workers}"
  user_data       = "${var.worker_user_data}"
  tags            = "${var.worker_tags}"

  manager_private_ip = "${element(module.managers.ipv4_addresses_private, 0)}"
  join_token         = "${module.managers.worker_token}"

  ssh_keys          = "${var.worker_ssh_keys}"
  provision_ssh_key = "${var.provision_ssh_key}"
  provision_user    = "${var.provision_user}"
}
