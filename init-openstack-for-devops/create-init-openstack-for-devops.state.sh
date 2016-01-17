#!/bin/bash

set -ex

# to empty init-openstack-for-devops.state
	cat /dev/null > init-openstack-for-devops.state

# for variable OpenStackImageID used in install-devops.sh 
	echo "export UBUNTU_IMAGE_ID=\"$UBUNTU_IMAGE_ID\"" >> init-openstack-for-devops.state

# for variable OpenStackNetID used in install-devops.sh 
	echo "export NETWORK_ID=\"$NETWORK_ID\"" >> init-openstack-for-devops.state
	echo "export SUBNET_ID=\"$SUBNET_ID\"" >> init-openstack-for-devops.state

# for IaaSVMSSHKeyContent used in install-devops.sh 
	echo "export SSH_KEY_CONTENT=\"$(sed ':a;N;$!ba;s/\n/|/g' $OS_TENANT_NAME.pem)\"" >> init-openstack-for-devops.state

# for variable OpenStackTenantName in install-devops.sh 
	echo "export OS_TENANT_NAME=\"$OS_TENANT_NAME\"" >> init-openstack-for-devops.state

# for variable OpenStackUserName in install-devops.sh
	echo "export OS_USERNAME=\"$OS_USERNAME\"" >> init-openstack-for-devops.state

# for variable OpenStackAPIKey in install-devops.sh
	echo "export OS_PASSWORD=\"$OS_PASSWORD\"" >> init-openstack-for-devops.state

# for variable IaaSVMSSHKeyName in install-devops.sh
	echo "export KEYPAIR_NAME=\"$OS_TENANT_NAME\"" >> init-openstack-for-devops.state

# for variable OpenStackSecurityGroupID in install-devops.sh
	echo "export SECURITY_GROUP_NAME=\"$OS_TENANT_NAME\"" >> init-openstack-for-devops.state

# for variable API_SERVER in install-devops.sh
	echo "export INSTALLER_FLOATING_IP=\"$INSTALLER_FLOATING_IP\"" >> init-openstack-for-devops.state

# for variable OpenStackAuthURL in install-devops.sh
	echo "export OS_AUTH_URL=\"$OS_AUTH_URL\"" >> init-openstack-for-devops.state

# for variable OpenStackNetIPPublicMicrobosh in install-devops.sh
	echo "export MICROBOSH_FLOATING_IP=\"$MICROBOSH_FLOATING_IP\"" >> init-openstack-for-devops.state

# for variable OpenStackNetIPPublicCF in install-devops.sh
	echo "export CF_FLOATING_IP=\"$CF_FLOATING_IP\"" >> init-openstack-for-devops.state

