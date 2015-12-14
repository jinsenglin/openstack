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
- [get-virtual-machines.sh , get-os-keypairs.sh , create-os-keypairs.sh , import-os-keypairs.sh , get-os-security-groups.sh] -> [get-nova-compute-service-public-url.sh , get-api-token.sh]
- show-nova-compute-service-public-url.sh -> get-nova-compute-service-public-url.sh
- [show-nova-compute-service.sh , get-nova-compute-service-public-url.sh] -> get-nova-compute-service.sh
- show-api-token.sh -> get-api-token.sh
- [show-api-services.sh , get-nova-compute-service.sh] -> get-api-services.sh
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
| import-os-keypairs.sh  | RESP_JSON_OS_KEYPAIRS_IMPORT  | "$public_ssh_key_content"  |
| get-os-security-groups.sh  | RESP_JSON_OS_SECGROUPS  |  |

API Versions

| Function  | Required API Version  | Current API Version used in Lab |
| ------------- | ------------- | ------------- |
| Create or import keypair  | Compute API v2.1  | Compute API v2  |
| Create default security group rule  | Compute API v2.1  | Compute API v2  |
