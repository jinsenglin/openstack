#!/bin/bash -ex

source auth-openstack.sh

export JSON_NOVA_COMPUTE_SERV=$(echo $RESP_JSON_AUTH | jq '.access.serviceCatalog[] | select(.name == "nova" and .type == "compute")')
