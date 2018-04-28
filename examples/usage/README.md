# Usage example

This example shows how to create the cluster, exposing the Docker remote API and configure some basic firewall rules.

## Requirements

- Certificates & keys to configure TLS. See certs/README.md on how to create those using cfssl.
- DigitalOcean API token

## Running it

You can try out this example by providing a digitalocean access token and running `terraform apply`. Note that you may need to run `terraform init` first.

This will create:

- a cluster with multiple managers and workers
- a load balancer to access the remote API
- cluster internal firewall rules
