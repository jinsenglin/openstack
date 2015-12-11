#!/bin/bash

set -ex

source auth-openstack.sh

echo $RESP_JSON_AUTH | jq '.access.token.id' | sed 's/"//g'
