#!/bin/bash -ex

source get-api-token.sh
source get-glance-image-service-public-url.sh

export RESP_JSON_IMAGES_CREATE=$(curl -s -X POST $GLANCE_IMAGE_SERV_PUBLIC_URL/v2/images \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN" \
	    -d "{
			\"container_format\": \"bare\",
			\"disk_format\": \"qcow2\",
			\"name\": \"img-$RANDOM\"
		}")
