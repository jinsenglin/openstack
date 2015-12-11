#!/bin/bash -ex

source get-nova-compute-service.sh

echo $JSON_NOVA_COMPUTE_SERV | jq '.'
