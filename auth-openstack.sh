#!/bin/bash

set -ex

source example-openrc.sh

RESP_JSON_AUTH=$(curl -s -X POST $OS_AUTH_URL/tokens \
            -H "Content-Type: application/json" \
            -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials":
            {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}')

export API_TOKEN=$(echo $RESP_JSON_AUTH | jq '.access.token.id' | sed 's/"//g')
