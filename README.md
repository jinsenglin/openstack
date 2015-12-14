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
- show-os-keypairs.sh -> get-os-keypairs.sh
- show-virtual-machines.sh -> get-virtual-machines.sh
- get-external-gateway.sh -> get-networks.sh
- [get-networks.sh , get-routers.sh] -> [get-neutron-network-service-public-url.sh , get-api-token.sh]
- [get-virtual-machines.sh , get-os-keypairs.sh , create-os-keypairs.sh , import-os-keypairs.sh , get-os-security-groups.sh , create-os-security-groups.sh] -> [get-nova-compute-service-public-url.sh , get-api-token.sh]
- show-nova-compute-service-public-url.sh -> get-nova-compute-service-public-url.sh
- [show-nova-compute-service.sh , get-nova-compute-service-public-url.sh] -> get-nova-compute-service.sh
- get-neutron-network-service-public-url.sh -> get-neutron-network-service.sh
- show-api-token.sh -> get-api-token.sh
- [show-api-services.sh , get-nova-compute-service.sh , get-neutron-network-service.sh , get-glance-image-service.sh] -> get-api-services.sh
- [get-api-token.sh , get-api-services.sh] -> auth-openstack.sh
- auth-openstack.sh -> example-openrc.sh
 
Example Usage
- bash show-virtual-machines.sh

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
| get-routers.sh  | RESP_JSON_ROUTERS  |  |
| get-networks.sh  | RESP_JSON_NETWORKS  |  |
| get-external-gateway.sh  | RESP_JSON_EXTERNAL_GW  |  |
| get-glance-image-service.sh  | JSON_GLANCE_IMAGE_SERV  |  |

API Versions

| Function  | Required API Version  | Current API Version used in Lab |
| ------------- | ------------- | ------------- |

Security Group related API Notes
- http://developer.openstack.org/api-ref-networking-v2-ext.html vs. http://developer.openstack.org/api-ref-compute-v2.1.html
