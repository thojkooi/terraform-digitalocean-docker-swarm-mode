variable "do_token" {
    description = "DigitalOcean API token with read/write permissions"
}

variable "domain" {
    description = "Domain name used in droplet hostnames, e.g example.com"
}

variable "manager_ssh_keys" {
    type = "list"
    description = "A list of SSH IDs or fingerprints to enable in the format [12345, 123456] that are added to manager nodes"
}

variable "worker_ssh_keys" {
    type = "list"
    description = "A list of SSH IDs or fingerprints to enable in the format [12345, 123456] that are added to worker nodes"
}

variable "provision_ssh_key" {
    default = "~/.ssh/id_rsa"
    description = "File path to SSH private key used to access the provisioned nodes. Ensure this key is listed in the manager and work ssh keys list"
}

variable "provision_user" {
    default = "core"
    description = "User used to log in to the droplets via ssh for issueing Docker commands"
}

variable "region" {
    description = "Datacenter region in which the cluster will be created"
    default = "ams3"
}

variable "total_managers" {
    description = "Total number of managers in cluster"
    default = 1
}

variable "total_workers" {
    description = "Total number of workers in cluster"
    default = 1
}
variable "manager_os" {
    description = "Operating system for the manager nodes"
    default = "coreos-alpha"
}
variable "worker_os" {
    description = "Operating system for the worker nodes"
    default = "coreos-alpha"
}

variable "manager_size" {
    description = "Droplet size of worker nodes"
    default = "512mb"
}
variable "worker_size" {
    description = "Droplet size of worker nodes"
    default = "512mb"
}

variable "manager_name" {
    description = "Prefix for name of manager nodes"
    default = "manager"
}
variable "worker_name" {
    description = "Prefix for name of worker nodes"
    default = "worker"
}

variable "manager_user_data" {
    description = "User data content for manager nodes. Use this for installing a configuration management tool, such as Puppet or installing Docker"
    default = ""
}

variable "worker_user_data" {
    description = "User data content for worker nodes. Use this for installing a configuration management tool, such as Puppet or installing Docker"
    default = ""
}

variable "manager_tags" {
    description = "List of DigitalOcean tag ids"
    default = []
    type = "list"
}
variable "worker_tags" {
    description = "List of DigitalOcean tag ids"
    default = []
    type = "list"
}
