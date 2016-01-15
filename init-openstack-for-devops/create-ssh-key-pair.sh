#!/bin/bash

set -ex

KEYPAIR_NAME=$1

# create ssh key pair
	nova keypair-add $KEYPAIR_NAME > $KEYPAIR_NAME.pem

# modify private key file permission
	chmod 600 $KEYPAIR_NAME.pem
