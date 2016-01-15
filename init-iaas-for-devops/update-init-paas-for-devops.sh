#!/bin/bash

set -ex

# to update OpenStackImageID with cloud-image-id
echo "export UBUNTU_IMAGE_ID=$UBUNTU_IMAGE_ID" >> init.openstack.for-devops.state

# to update OpenStackNetID with subnet-id
echo "export SUBNET_ID=$SUBNET_ID" >> init.openstack.for-devops.state

# to update IaaSVMSSHKeyContent with ssh-private-key-content
echo "export SSH_KEY_CONTENT=$(sed ':a;N;$!ba;s/\n/|/g' $OS_TENANT_NAME.pem)" >> init.openstack.for-devops.state

# to update OpenStackTenantName with
echo "export OS_TENANT_NAME=$OS_TENANT_NAME" >> init.openstack.for-devops.state
# to update OpenStackUserName with
echo "export OS_USERNAME=$OS_USERNAME" >> init.openstack.for-devops.state
# to update OpenStackAPIKey with
echo "export OS_PASSWORD=$OS_PASSWORD" >> init.openstack.for-devops.state
# to update IaaSVMSSHKeyName with
echo "export KEYPAIR_NAME=$OS_TENANT_NAME" >> init.openstack.for-devops.state
# to update OpenStackSecurityGroupID with
echo "export SECURITY_GROUP_NAME=$OS_TENANT_NAME" >> init.openstack.for-devops.state

# to update API_SERVER
echo "export INSTALLER_FLOATING_IP=$INSTALLER_FLOATING_IP" >> init.openstack.for-devops.state

# to update OpenStackAuthURL
echo "export OS_AUTH_URL=$OS_AUTH_URL" >> init.openstack.for-devops.state

# to update OpenStackNetIPPublicMicrobosh
echo "export MICROBOSH_FLOATING_IP=$MICROBOSH_FLOATING_IP" >> init.openstack.for-devops.state

# to update OpenStackNetIPPublicCF
echo "export CF_FLOATING_IP=$CF_FLOATING_IP" >> init.openstack.for-devops.state

