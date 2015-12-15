#!/bin/bash -ex

if [ $# -lt 1 ]; then
	echo "Usage: $([ -z $BASH_ARGV ] && basename $0 || basename $BASH_ARGV) <external gateway network id>"
	exit 1
fi

source get-api-token.sh
source get-neutron-network-service-public-url.sh

export RESP_JSON_ROUTERS_CREATE=$(curl -s -X POST $NEUTRON_NETWORK_SERV_PUBLIC_URL/v2.0/routers \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN" \
	    -d "{
			\"router\": {
				\"external_gateway_info\": {
					\"network_id\": \"$1\"
				},
				\"name\": \"router-$RANDOM\"
			}
		}")
