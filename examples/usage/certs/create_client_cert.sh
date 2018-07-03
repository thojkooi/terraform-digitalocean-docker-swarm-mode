#!/bin/bash

export ADDRESS=
export NAME=$1
echo '{"CN":"'$NAME'","hosts":[""],"key":{"algo":"rsa","size":4096}}' | cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem -hostname="$ADDRESS" - | cfssljson -bare $NAME
