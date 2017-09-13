#!/bin/bash

function query() {
openstack quota list --compute
openstack quota list --volume
openstack quota list --network
}

query
