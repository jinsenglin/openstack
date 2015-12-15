#!/bin/bash -ex

source get-glance-image-service.sh

export GLANCE_IMAGE_SERV_PUBLIC_URL=$(echo $JSON_GLANCE_IMAGE_SERV | jq '.endpoints[0].publicURL' | sed 's/"//g')
