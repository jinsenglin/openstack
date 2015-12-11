#!/bin/bash -ex

source get-virtual-machines.sh

echo $RESP_JSON_SERVERS | jq '.'
