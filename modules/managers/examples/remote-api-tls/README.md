# Remote API TLS

Create managers and expose the Docker Remote API over TLS.

For this, you need to create certificates and keys.

### Creating CA and server certificates

This is an example using cfssl, following the [CoreOS self signed certificates](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html) docs.

More references can be found:

- https://coreos.com/os/docs/latest/generate-self-signed-certificates.html
- https://docs.docker.com/engine/security/https/#create-a-ca-server-and-client-keys-with-openssl


```bash
echo '{"CN":"CA","key":{"algo":"rsa","size":4096}}' | cfssl gencert -initca - | cfssljson -bare ca -
echo '{"signing":{"default":{"expiry":"43800h","usages":["signing","key encipherment","server auth","client auth"]}}}' > ca-config.json
export ADDRESS=example.com
export NAME=server
echo '{"CN":"'$NAME'","hosts":[""],"key":{"algo":"rsa","size":4096}}' | cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem -hostname="$ADDRESS" - | cfssljson -bare $NAME
```

Upgrade the `ADDRESS` variable to match the host name / address used to access the Docker API.

### Create the client certificates

```bash
export ADDRESS=
export NAME=client
echo '{"CN":"'$NAME'","hosts":[""],"key":{"algo":"rsa","size":4096}}' | cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem -hostname="$ADDRESS" - | cfssljson -bare $NAME
```

### Create the managers

```
$ terraform apply

data.template_file.provision_manager: Refreshing state...
data.template_file.provision_first_manager: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)
....
Plan: 18 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

You can use the client certificates to access the docker api.
