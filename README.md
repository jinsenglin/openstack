# openstack

Downloading OpenStack RC File
- Use browser to visit Horizon dashboard
- Login Horizon
- Click 'Project' in the left-side menu
- Click 'Compute' under the 'Project' menu
- Click 'Access & Security' under the 'Compute' menu
- Click 'API Access' in the top menu of the right-side page
- Click 'Download OpenStack RC File'

Getting TryStack API Password
- Use browser to visit Horizon dashboard
- Login Horizon with Facebook Account
- Click 'Settings' in the left-side menu
- Click 'API Password' under the 'Settings' menu
- Click 'Request API password' button in the right-side page

Dependency
- [upload-images.sh , download-images.sh , create-images.sh , get-images.sh] -> [get-glance-image-service-public-url.sh , get-api-token.sh]
- show-os-keypairs.sh -> get-os-keypairs.sh
- show-virtual-machines.sh -> get-virtual-machines.sh
- get-external-gateway-network-subnet-id.sh -> get-external-gateway-network.sh
- get-external-gateway-network-id.sh -> get-external-gateway-network.sh
- get-external-gateway-network.sh -> get-networks.sh
- [create-security-group-rules.sh , get-security-group-rules.sh , create-security-groups.sh , get-security-groups.sh , add-router-interface.sh , create-subnets.sh , get-subnets.sh , create-networks.sh , get-networks.sh , create-routers.sh , get-routers.sh] -> [get-neutron-network-service-public-url.sh , get-api-token.sh]
- [get-virtual-machines.sh , get-os-keypairs.sh , create-os-keypairs.sh , import-os-keypairs.sh , get-os-security-groups.sh , create-os-security-groups.sh , create-os-security-group-rules.sh] -> [get-nova-compute-service-public-url.sh , get-api-token.sh]
- show-nova-compute-service-public-url.sh -> get-nova-compute-service-public-url.sh
- [show-nova-compute-service.sh , get-nova-compute-service-public-url.sh] -> get-nova-compute-service.sh
- get-neutron-network-service-public-url.sh -> get-neutron-network-service.sh
- get-glance-image-service-public-url.sh -> get-glance-image-service.sh
- show-api-token.sh -> get-api-token.sh
- [show-api-services.sh , get-nova-compute-service.sh , get-neutron-network-service.sh , get-glance-image-service.sh] -> get-api-services.sh
- [get-api-token.sh , get-api-services.sh] -> auth-openstack.sh
- auth-openstack.sh -> example-openrc.sh
 
Example Usage
- bash show-virtual-machines.sh
- source auth-openstack.sh && echo $RESP_JSON_AUTH | jq '.'

Example Usage for Debugging
- ./show-virtual-machines.sh

Argument and Exported Environment Variable

| Script  | Exported Variable | Argument |
| ------------- | ------------- | ------------- |
| example-openrc.sh  | OS_AUTH_URL , OS_TENANT_ID , OS_TENANT_NAME , OS_PROJECT_NAME , OS_USERNAME , OS_PASSWORD , OS_REGION_NAME  |  |
| auth-openstack.sh  | RESP_JSON_AUTH  |  |
| get-api-token.sh  | API_TOKEN  |  |
| get-nova-compute-service.sh  | JSON_NOVA_COMPUTE_SERV  |  |
| get-nova-compute-service-public-url.sh  | NOVA_COMPUTE_SERV_PUBLIC_URL  |  |
| get-virtual-machines.sh  | RESP_JSON_SERVERS  |  |
| get-api-services.sh  | API_SERVICES  |  |
| get-os-keypairs.sh  | RESP_JSON_OS_KEYPAIRS  |  |
| create-os-keypairs.sh  | RESP_JSON_OS_KEYPAIRS_CREATE  |  |
| import-os-keypairs.sh  | RESP_JSON_OS_KEYPAIRS_IMPORT  | "$public_sshkey_content"  |
| get-os-security-groups.sh  | RESP_JSON_OS_SECGROUPS  |  |
| create-os-security-groups.sh  | RESP_JSON_OS_SECGROUPS_CREATE  |  |
| create-os-security-group-rules.sh  | RESP_JSON_OS_SECGROUP_RULES_CREATE  | "$parent_secgroup_id"  |
| get-neutron-network-service.sh  | JSON_NEUTRON_NETWORK_SERV  |  |
| get-neutron-network-service-public-url.sh  | NEUTRON_NETWORK_SERV_PUBLIC_URL  |  |
| get-glance-image-service-public-url.sh  | GLANCE_IMAGE_SERV_PUBLIC_URL  |  |
| get-routers.sh  | RESP_JSON_ROUTERS  |  |
| create-routers.sh  | RESP_JSON_ROUTERS_CREATE  | "$external_gw_network_id"  |
| get-networks.sh  | RESP_JSON_NETWORKS  |  |
| create-networks.sh  | RESP_JSON_NETWORKS_CREATE  |  |
| get-subnets.sh  | RESP_JSON_SUBNETS  |  |
| create-subnets.sh  | RESP_JSON_SUBNETS_CREATE  | "$network_id"  |
| get-external-gateway-network.sh  | EXTERNAL_GW_NET  |  |
| get-external-gateway-network-id.sh  | EXTERNAL_GW_NET_ID  |  |
| get-external-gateway-network-subnet-id.sh  | EXTERNAL_GW_NET_SUBNET_ID  |  |
| get-glance-image-service.sh  | JSON_GLANCE_IMAGE_SERV  |  |
| add-router-interface.sh  | RESP_JSON_ADD_ROUTER_IF  | "$router_id" "$subnet_id"  |
| get-security-groups.sh  | RESP_JSON_SECURITY_GROUPS  |  |
| create-security-groups.sh  | RESP_JSON_SECURITY_GROUPS_CREATE  |  |
| get-security-group-rules.sh  | RESP_JSON_SECURITY_GROUP_RULES  |  |
| create-security-group-rules.sh  | RESP_JSON_SECURITY_GROUP_RULES_CREATE  | "$sg_id"  |
| get-images.sh  | RESP_JSON_IMAGES  |  |
| create-images.sh  | RESP_JSON_IMAGES_CREATE  |  |
| download-images.sh  |  | "$image_id"  |
| upload-images.sh  |  | "$image_id" "$image_file_path"  |

API Versions

| Function  | Required API Version  | Current API Version used in Lab |
| ------------- | ------------- | ------------- |

Security Group related API Notes
- http://developer.openstack.org/api-ref-networking-v2-ext.html vs. http://developer.openstack.org/api-ref-compute-v2.1.html
- Can specify direction vs. Can't
- RESP_JSON_SECURITY_GROUPS_CREATE vs. RESP_JSON_OS_SECGROUPS_CREATE
- create-security-groups.sh vs. create-os-security-groups.sh
- RESP_JSON_SECURITY_GROUPS vs. RESP_JSON_OS_SECGROUPS
- get-security-groups.sh vs. get-os-security-groups.sh
- RESP_JSON_SECURITY_GROUP_RULES_CREATE vs. RESP_JSON_OS_SECGROUP_RULES_CREATE
- create-security-group-rules.sh vs. create-os-security-group-rules.sh
- RESP_JSON_SECURITY_GROUP_RULES vs N/A
- get-security-group-rules.sh vs N/A

Bugs
- upload-images.sh (always only upload half size of the given file , WHY?)
