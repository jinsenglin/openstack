#!/bin/bash -ex

source get-api-services.sh

export JSON_NOVA_COMPUTE_SERV=$(echo $API_SERVICES | jq '.[] | select(.name == "nova" and .type == "compute")')
