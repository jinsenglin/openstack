#!/bin/bash -ex

source auth-openstack.sh

export API_TOKEN=$(echo $RESP_JSON_AUTH | jq '.access.token.id' | sed 's/"//g')
