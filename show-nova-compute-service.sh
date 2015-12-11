#!/bin/bash

set -ex

source auth-openstack.sh

echo $RESP_JSON_AUTH | jq '.access.serviceCatalog[] | select(.name == "nova" and .type == "compute")'
