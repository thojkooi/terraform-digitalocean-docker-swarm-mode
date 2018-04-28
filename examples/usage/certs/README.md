# Generate certificates

How to create certificates to configure the Docker Remote API using TLS.

References:
- https://coreos.com/os/docs/latest/generate-self-signed-certificates.html
- https://docs.docker.com/engine/security/https/#create-a-ca-server-and-client-keys-with-openssl

## Using cfssl

This is following the [CoreOS self signed certificates](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html) docs.

### Installing

https://github.com/cloudflare/cfssl#installation

### Creating certificates

```bash
./create_certificates.sh example.com
```

> **Please keep ca-key.pem file in safe**. This key allows to create any kind of certificates within your CA.

You can create as many client certificates as you want, just repeat the proces.

### Prepare docker client access

Create the client certificates:
```bash
# Create certificate with CN=client
./create_client_cert.sh client

# Create certificate with CN=admin
./create_client_cert.sh admin
```

When you generated the client certificates, you need a copy of the `ca.pem`, the `client.pem` and `client-key.pem` files to authenticate with the Docker API. To do so, move those files to your `~/.docker` directory. Alternatively, use a different directory and configure `DOCKER_CERT_PATH`.

```bash
mkdir ~/.docker
cp ca.pem ~/.docker/ca.pem
mv client.pem ~/.docker/cert.pem
mv client-key.pem ~/.docker/key.pem
```

```bash
export DOCKER_CERT_PATH=~/.docker
```

Alternatively, run `install-client-bundle.sh` to configure the API access:

```bash
source install-client-bundle.sh example.com
```
