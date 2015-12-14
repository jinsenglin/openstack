#!/bin/bash -ex

source get-api-token.sh
source get-neutron-network-service-public-url.sh

export RESP_JSON_NETWORKS_CREATE=$(curl -s -X POST $NEUTRON_NETWORK_SERV_PUBLIC_URL/v2.0/networks \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN" \
	    -d "{
			\"network\": {
				\"name\": \"net-$RANDOM\",
				\"admin_state_up\": true
			}
	       }")
