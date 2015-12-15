#!/bin/bash -ex

if [ $# -lt 1 ]; then
	echo "Usage: $([ -z $BASH_ARGV ] && basename $0 || basename $BASH_ARGV) <image id>"
	exit 1
fi

source get-api-token.sh
source get-glance-image-service-public-url.sh

curl -o $RANDOM.img -i -X GET $GLANCE_IMAGE_SERV_PUBLIC_URL/v2/images/$1/file \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN"
