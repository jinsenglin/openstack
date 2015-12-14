#!/bin/bash -ex

if [ $# -lt 1 ]; then
        echo "Usage: $0 <parent security group id>"
        exit 1
fi

source get-api-token.sh
source get-nova-compute-service-public-url.sh

export RESP_JSON_OS_SECGROUP_RULES_CREATE=$(curl -s -X POST $NOVA_COMPUTE_SERV_PUBLIC_URL/os-security-group-rules \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $API_TOKEN" \
	    -d "{
			\"security_group_rule\": {
				\"from_port\": \"443\",
				\"ip_protocol\": \"tcp\",
				\"to_port\": \"443\",
				\"cidr\": \"0.0.0.0/0\",
				\"parent_group_id\": \"$1\"
			}
		}")
