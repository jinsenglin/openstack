#!/bin/bash -ex

if [ $# -lt 2 ]; then
	echo "Usage: $([ -z $BASH_ARGV ] && basename $0 || basename $BASH_ARGV) <image id> <image file path>"
	exit 1
fi

source get-api-token.sh
source get-glance-image-service-public-url.sh

curl -i -X PUT $GLANCE_IMAGE_SERV_PUBLIC_URL/v2/images/$1/file \
            -H "Content-Type: application/octet-stream" \
            -H "X-Auth-Token: $API_TOKEN" \
	    -d @$2
