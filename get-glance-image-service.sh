#!/bin/bash -ex

source get-api-services.sh

export JSON_GLANCE_IMAGE_SERV=$(echo $API_SERVICES | jq '.[] | select(.name == "glance" and .type == "image")')
