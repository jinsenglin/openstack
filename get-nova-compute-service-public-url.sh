#!/bin/bash -ex

source get-nova-compute-service.sh

export NOVA_COMPUTE_SERV_PUBLIC_URL=$(echo $JSON_NOVA_COMPUTE_SERV | jq '.endpoints[0].publicURL' | sed 's/"//g')
