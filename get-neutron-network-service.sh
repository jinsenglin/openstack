#!/bin/bash -ex

source get-api-services.sh

export JSON_NEUTRON_NETWORK_SERV=$(echo $API_SERVICES | jq '.[] | select(.name == "neutron" and .type == "network")')
