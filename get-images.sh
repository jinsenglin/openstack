#!/bin/bash -ex

source get-api-token.sh
source get-glance-image-service-public-url.sh

export RESP_JSON_IMAGES=$(curl -s -X GET $GLANCE_IMAGE_SERV_PUBLIC_URL/v2/images \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN")
