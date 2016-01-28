#!/bin/bash

set -ex

for id in $(neutron net-list | grep "^|" | grep -v "^| id" | awk '{print $2}')
do
	neutron net-show $id | tee neutron-net-show.state 
	if [ "$(grep 'router:external' neutron-net-show.state | awk '{print $4}')" == "True" ]; then
		echo "export EXTERNAL_NET_ID=$id" > query-external-net-id.state 
		exit 0
	fi
done
