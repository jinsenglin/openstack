#!/bin/bash -ex

source get-os-keypairs.sh

echo $RESP_JSON_OS_KEYPAIRS | jq '.'
