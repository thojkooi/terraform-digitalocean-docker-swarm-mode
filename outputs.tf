
output "manager_ips" {
  value = ["${digitalocean_droplet.manager.*.ipv4_address}"]
  description = "The manager nodes public ipv4 adresses"
}

output "manager_ips_private" {
  value = ["${digitalocean_droplet.manager.*.ipv4_address_private}"]
  description = "The manager nodes private ipv4 adresses"
}

output "worker_ips" {
  value = ["${digitalocean_droplet.worker.*.ipv4_address}"]
  description = "The worker nodes public ipv4 adresses"
}

output "worker_ips_private" {
  value = ["${digitalocean_droplet.worker.*.ipv4_address_private}"]
  description = "The worker nodes private ipv4 adresses"
}

output "manager_token" {
  value = "${data.external.swarm_tokens.result.manager}"
  description = "The Docker Swarm manager join token"
  sensitive = true
}

output "worker_token" {
  value = "${data.external.swarm_tokens.result.worker}"
  description = "The Docker Swarm worker join token"
  sensitive = true
}
