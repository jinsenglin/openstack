# openstack

Downloading OpenStack RC File
- Use browser to visit Horizon dashboard
- Login Horizon
- Click 'Project' in the left-side menu
- Click 'Compute' under the 'Project' menu
- Click 'Access & Security' under the 'Compute' menu
- Click 'API Access' in the top menu of the right-side page
- Click 'Download OpenStack RC File'

Dependency
- [show-nova-compute-service-public-url.sh , get-virtual-machines.sh] -> get-nova-compute-service-public-url.sh
- [show-nova-compute-service.sh , get-nova-compute-service-public-url.sh] -> get-nova-compute-service.sh
- show-api-token.sh -> get-api-token.sh
- [get-nova-compute-service.sh , get-api-token.sh] -> auth-openstack.sh -> example-openrc.sh
 
Example Usage
- bash show-nova-compute-service-public-url.sh
- bash show-nova-compute-service.sh
- bash show-api-token.sh

Debugging
- ./auth-openstack.sh
- ./get-api-token.sh
- ./get-nova-compute-service.sh
- ./show-api-token.sh
- ./show-nova-compute-service.sh
- ./get-nova-compute-service-public-url.sh
- ./show-nova-compute-service-public-url.sh
- ./get-virtual-machines.sh

Exported Variable

| Script  | Variable |
| ------------- | ------------- |
| example-openrc.sh  | OS_AUTH_URL , OS_TENANT_ID , OS_TENANT_NAME , OS_PROJECT_NAME , OS_USERNAME , OS_PASSWORD , OS_REGION_NAME  |
| auth-openstack.sh  | RESP_JSON_AUTH  |
| get-api-token.sh  | API_TOKEN  |
| get-nova-compute-service.sh  | JSON_NOVA_COMPUTE_SERV  |
| get-nova-compute-service-public-url.sh  | NOVA_COMPUTE_SERV_PUBLIC_URL  |
| get-virtual-machines.sh  | ?  |
