#!/bin/bash -ex

source auth-openstack.sh

export API_SERVICES=$(echo $RESP_JSON_AUTH | jq '.access.serviceCatalog')
