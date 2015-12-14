#!/bin/bash -ex

source get-api-token.sh
source get-nova-compute-service-public-url.sh

export RESP_JSON_OS_KEYPAIRS=$(curl -s -X GET $NOVA_COMPUTE_SERV_PUBLIC_URL/os-keypairs \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN")
