#!/bin/bash -ex

if [ $# -lt 1 ]; then
	echo "Usage: $([ -z $BASH_ARGV ] && basename $0 || basename $BASH_ARGV) <security group id>"
	exit 1
fi

source get-api-token.sh
source get-neutron-network-service-public-url.sh

export RESP_JSON_SECURITY_GROUP_RULES_CREATE=$(curl -s -X POST $NEUTRON_NETWORK_SERV_PUBLIC_URL/v2.0/security-group-rules \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN" \
	    -d "{
			\"security_group_rule\": {
				\"security_group_id\": \"$1\",
				\"direction\": \"ingress\",
				\"protocol\": \"tcp\",
				\"port_range_min\": \"80\",
				\"port_range_max\": \"80\",
				\"remote_ip_prefix\": \"0.0.0.0/0\",
				\"ethertype\": \"IPv4\"
			}
		}")
