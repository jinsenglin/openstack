#!/bin/bash

set -ex

ROUTER_ID=$1
SUBNET_ID=$2

neutron router-interface-add $ROUTER_ID $SUBNET_ID
