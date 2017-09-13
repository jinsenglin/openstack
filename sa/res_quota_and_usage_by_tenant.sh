#!/bin/bash

function query() {
openstack limits show --absolute --project $TENANT
}

echo jimlin
TENANT=5593c57c2c7b471788f0c25aee36e44f
query

echo willyhu
TENANT=37109e3b707148a5a980d14941860959
query

echo alan
TENANT=e256e733bf9449918a88ec668615ce17
query

echo robin_project
TENANT=21a15aa8c9b048e287f7c844b852f5ac
query

echo devops
TENANT=4eae34b5730c471a81303e8f484d9859
query

echo tony_gnocchi_for_grafana
TENANT=fd1fb95fb2534b35a4743c7a383ff1c2
query
