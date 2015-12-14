#!/bin/bash -ex

source get-api-services.sh

echo $API_SERVICES | jq '.'
