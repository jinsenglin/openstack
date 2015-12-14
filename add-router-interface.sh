#!/bin/bash -ex

if [ $# -lt 2 ]; then
	echo "Usage: $0 <router id> <subnet id>"
	exit 1
fi

source get-api-token.sh
source get-neutron-network-service-public-url.sh

export RESP_JSON_ADD_ROUTER_IF=$(curl -s -X PUT $NEUTRON_NETWORK_SERV_PUBLIC_URL/v2.0/routers/$1/add_router_interface \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN" \
	    -d "{
			\"subnet_id\": \"$2\"
		}")
