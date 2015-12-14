#!/bin/bash -ex

source get-api-token.sh
source get-neutron-network-service-public-url.sh

export RESP_JSON_SUBNETS=$(curl -s -X GET $NEUTRON_NETWORK_SERV_PUBLIC_URL/v2.0/subnets \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN")
