#!/bin/bash -ex

if [ $# -lt 1 ]; then
	echo "Usage: $([ -z $BASH_ARGV ] && basename $0 || basename $BASH_ARGV) <public ssh key content>"
	exit 1
fi

source get-api-token.sh
source get-nova-compute-service-public-url.sh

export RESP_JSON_OS_KEYPAIRS_IMPORT=$(curl -s -X POST $NOVA_COMPUTE_SERV_PUBLIC_URL/os-keypairs \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN" \
	    -d "{
			\"keypair\": {
				\"name\": \"sshkey-$RANDOM\",
				\"public_key\": \"$1\"
			}
		}")
