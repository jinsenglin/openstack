#!/bin/bash

# api call sequences
#	01. create_mysql_vm
# 	02. create_ldap_vm
#	03. create_inception_vm
#	04. create_apim_vm
#	05. create_idp_vm
#	06. create_ossapi_vm
#	07. create_ossui_vm
#	08. create_nginx_vm
#	09. install_mysql
# 	10. install_ldap
#	11. install_apim
#	12. install_idp	
#	13. install_nginx
#	14. install_inception
#	15. install_microbosh
#	16. install_cf
#	17. install_ossapi
#	18. install_ossui

set -ex

source init-openstack-for-devops.state

function step0() {
  API_SERVER="http://$INSTALLER_FLOATING_IP:9000"

  IaaSVMSSHKeyContent="${SSH_KEY_CONTENT::-1}"
  IaaSVMSSHKeyName="$KEYPAIR_NAME"

  OpenStackImageID="$UBUNTU_IMAGE_ID"
# OpenStackNetID="$SUBNET_ID"
  OpenStackNetID="$NETWORK_ID"
  OpenStackTenantName="$OS_TENANT_NAME"
  OpenStackUserName="$OS_USERNAME"
  OpenStackAPIKey="$OS_PASSWORD"
  OpenStackSecurityGroupID="$SECURITY_GROUP_NAME"
  OpenStackAuthURL="$OS_AUTH_URL"
  OpenStackNetIPPublicMicrobosh="$MICROBOSH_FLOATING_IP"
  OpenStackNetIPPublicCF="$CF_FLOATING_IP"

  IaaSVMSSHAccount="ubuntu"
  OpenStackNetDNS="8.8.8.8"
  OpenStackNetGateway="192.168.100.1"
  OpenStackNetIPPrivateMicrobosh="192.168.100.100"
  OpenStackNetRange="192.168.100.0/24"
  OpenStackNetCFIPEnd="192.168.100.120"
  OpenStackNetCFIPReservedEnd="192.168.100.100"
  OpenStackNetCFIPReservedStart="192.168.100.2"
  OpenStackNetCFIPStart="192.168.100.101"
  OpenStackNetIPPrivateCFConsul="192.168.100.101"
  OpenStackNetIPPrivateCFEtcd="192.168.100.102"
  OpenStackNetIPPrivateCFHaproxy="192.168.100.103"
  OpenStackNetIPPrivateCFNats="192.168.100.104"
  OpenStackNetIPPrivateCFNfs="192.168.100.105"
  OpenStackNetIPPrivateCFPostgres="192.168.100.106"
  OpenStackNetIPPrivateCFRouter="192.168.100.107"
  OpenStackNetIPPrivateCFRunner="192.168.100.108"
}

function step1() {
  echo "# Step create_mysql_vm" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  RESP_CREATE_MYSQL_VM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaaSType\": \"openstack\",
  \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
  \"openStackAPIKey\": \"$OpenStackAPIKey\",
  \"openStackAuthURL\": \"$OpenStackAuthURL\",
  \"openStackFlavorID\": \"2\",
  \"openStackImageID\": \"$OpenStackImageID\",
  \"openStackNetID\": \"$OpenStackNetID\",
  \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
  \"openStackTenantName\": \"$OpenStackTenantName\",
  \"openStackUserName\": \"$OpenStackUserName\"
  }" $API_SERVER/task/create_mysql_vm?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export RESP_CREATE_MYSQL_VM='$RESP_CREATE_MYSQL_VM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_CREATE_MYSQL_VM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step2() {
  echo "# Step create_ldap_vm" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  RESP_CREATE_LDAP_VM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaaSType\": \"openstack\",
  \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
  \"openStackAPIKey\": \"$OpenStackAPIKey\",
  \"openStackAuthURL\": \"$OpenStackAuthURL\",
  \"openStackFlavorID\": \"2\",
  \"openStackImageID\": \"$OpenStackImageID\",
  \"openStackNetID\": \"$OpenStackNetID\",
  \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
  \"openStackTenantName\": \"$OpenStackTenantName\",
  \"openStackUserName\": \"$OpenStackUserName\"
  }" $API_SERVER/task/create_ldap_vm?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export RESP_CREATE_LDAP_VM='$RESP_CREATE_LDAP_VM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_CREATE_LDAP_VM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step3() {
  echo "# Step create_inception_vm" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  RESP_CREATE_INCEPTION_VM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaaSType\": \"openstack\",
  \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
  \"openStackAPIKey\": \"$OpenStackAPIKey\",
  \"openStackAuthURL\": \"$OpenStackAuthURL\",
  \"openStackFlavorID\": \"2\",
  \"openStackImageID\": \"$OpenStackImageID\",
  \"openStackNetID\": \"$OpenStackNetID\",
  \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
  \"openStackTenantName\": \"$OpenStackTenantName\",
  \"openStackUserName\": \"$OpenStackUserName\"
  }" $API_SERVER/task/create_inception_vm?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export RESP_CREATE_INCEPTION_VM='$RESP_CREATE_INCEPTION_VM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_CREATE_INCEPTION_VM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step4() {
  echo "# Step create_apim_vm" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  RESP_CREATE_APIM_VM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaaSType\": \"openstack\",
  \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
  \"openStackAPIKey\": \"$OpenStackAPIKey\",
  \"openStackAuthURL\": \"$OpenStackAuthURL\",
  \"openStackFlavorID\": \"2\",
  \"openStackImageID\": \"$OpenStackImageID\",
  \"openStackNetID\": \"$OpenStackNetID\",
  \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
  \"openStackTenantName\": \"$OpenStackTenantName\",
  \"openStackUserName\": \"$OpenStackUserName\"
  }" $API_SERVER/task/create_apim_vm?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export RESP_CREATE_APIM_VM='$RESP_CREATE_APIM_VM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_CREATE_APIM_VM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step5() {
  echo "# Step create_idp_vm" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  RESP_CREATE_IDP_VM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaaSType\": \"openstack\",
  \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
  \"openStackAPIKey\": \"$OpenStackAPIKey\",
  \"openStackAuthURL\": \"$OpenStackAuthURL\",
  \"openStackFlavorID\": \"2\",
  \"openStackImageID\": \"$OpenStackImageID\",
  \"openStackNetID\": \"$OpenStackNetID\",
  \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
  \"openStackTenantName\": \"$OpenStackTenantName\",
  \"openStackUserName\": \"$OpenStackUserName\"
  }" $API_SERVER/task/create_idp_vm?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export RESP_CREATE_IDP_VM='$RESP_CREATE_IDP_VM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_CREATE_IDP_VM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step6() {
  echo "# Step create_ossapi_vm" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  RESP_CREATE_OSSAPI_VM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaaSType\": \"openstack\",
  \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
  \"openStackAPIKey\": \"$OpenStackAPIKey\",
  \"openStackAuthURL\": \"$OpenStackAuthURL\",
  \"openStackFlavorID\": \"2\",
  \"openStackImageID\": \"$OpenStackImageID\",
  \"openStackNetID\": \"$OpenStackNetID\",
  \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
  \"openStackTenantName\": \"$OpenStackTenantName\",
  \"openStackUserName\": \"$OpenStackUserName\"
  }" $API_SERVER/task/create_ossapi_vm?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export RESP_CREATE_OSSAPI_VM='$RESP_CREATE_OSSAPI_VM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_CREATE_OSSAPI_VM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}


function step7() {
  echo "# Step create_ossui_vm" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  RESP_CREATE_OSSUI_VM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaaSType\": \"openstack\",
  \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
  \"openStackAPIKey\": \"$OpenStackAPIKey\",
  \"openStackAuthURL\": \"$OpenStackAuthURL\",
  \"openStackFlavorID\": \"2\",
  \"openStackImageID\": \"$OpenStackImageID\",
  \"openStackNetID\": \"$OpenStackNetID\",
  \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
  \"openStackTenantName\": \"$OpenStackTenantName\",
  \"openStackUserName\": \"$OpenStackUserName\"
  }" $API_SERVER/task/create_ossui_vm?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export RESP_CREATE_OSSUI_VM='$RESP_CREATE_OSSUI_VM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_CREATE_OSSUI_VM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step8() {
  echo "# Step create_nginx_vm" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  RESP_CREATE_NGINX_VM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaaSType\": \"openstack\",
  \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
  \"openStackAPIKey\": \"$OpenStackAPIKey\",
  \"openStackAuthURL\": \"$OpenStackAuthURL\",
  \"openStackFlavorID\": \"2\",
  \"openStackImageID\": \"$OpenStackImageID\",
  \"openStackNetID\": \"$OpenStackNetID\",
  \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
  \"openStackTenantName\": \"$OpenStackTenantName\",
  \"openStackUserName\": \"$OpenStackUserName\"
  }" $API_SERVER/task/create_nginx_vm?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export RESP_CREATE_NGINX_VM='$RESP_CREATE_NGINX_VM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_CREATE_NGINX_VM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step9() {
  echo "# Step install_mysql" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  MYSQL_IP=$(echo $RESP_CREATE_MYSQL_VM | jq '.artifact.mysqlVMEndpoint' | sed 's/"//g')
  RESP_INSTALL_MYSQL=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\"
  },
  \"mysql\": {
    \"mysqlVMEndpoint\": \"$MYSQL_IP\"
  }
  }" $API_SERVER/task/install_mysql?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export MYSQL_IP='$MYSQL_IP'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_MYSQL='$RESP_INSTALL_MYSQL'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_MYSQL" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step10() {
  echo "# Step install_ldap" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  LDAP_IP=$(echo $RESP_CREATE_LDAP_VM | jq '.artifact.ldapvmendpoint' | sed 's/"//g')
  RESP_INSTALL_LDAP=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\"
  },
  \"ldap\": {
    \"ldapvmendpoint\": \"$LDAP_IP\"
  }
  }" $API_SERVER/task/install_ldap?api_key=apiKey&api_key=apiKey)
  RESP_INSTALL_LDAP=$(echo $RESP_INSTALL_LDAP | sed 's/&amp;/\&/g')

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export LDAP_IP='$LDAP_IP'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_LDAP='$RESP_INSTALL_LDAP'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_LDAP" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step11() {
  echo "# Step install_apim" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  APIM_IP=$(echo $RESP_CREATE_APIM_VM | jq '.artifact.apimvmendpoint' | sed 's/"//g')
  LDAP_IP=$(echo $RESP_CREATE_LDAP_VM | jq '.artifact.ldapvmendpoint' | sed 's/"//g')
  LDAP_SEARCHBASE=$(echo $RESP_INSTALL_LDAP | jq '.artifact.searchBase' | sed 's/"//g')
  LDAP_URL=$(echo $RESP_INSTALL_LDAP | jq '.artifact.url' | sed 's/"//g')
  LDAP_USERDN=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userDN' | sed 's/"//g')
  LDAP_USERPASSWORD=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userPassword' | sed 's/"//g')
  LDAP_groupNameAttribute=$(echo $RESP_INSTALL_LDAP | jq '.artifact.groupNameAttribute' | sed 's/"//g')
  LDAP_groupNameListFilter=$(echo $RESP_INSTALL_LDAP | jq '.artifact.groupNameListFilter' | sed 's/"//g')
  LDAP_groupNameSearchFilter=$(echo $RESP_INSTALL_LDAP | jq '.artifact.groupNameSearchFilter' | sed 's/"//g')
  LDAP_groupSearchBase=$(echo $RESP_INSTALL_LDAP | jq '.artifact.groupSearchBase' | sed 's/"//g')
  LDAP_userNameAttribute=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userNameAttribute' | sed 's/"//g')
  LDAP_userNameListFilter=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userNameListFilter' | sed 's/"//g')
  LDAP_userNameSearchFilter=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userNameSearchFilter' | sed 's/"//g')
  RESP_INSTALL_APIM=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"apim\": {
    \"apimvmendpoint\": \"$APIM_IP\"
  },
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\"
  },
  \"ldap\": {
    \"groupNameAttribute\": \"$LDAP_groupNameAttribute\",
    \"groupNameListFilter\": \"$LDAP_groupNameListFilter\",
    \"groupNameSearchFilter\": \"$LDAP_groupNameSearchFilter\",
    \"groupSearchBase\": \"$LDAP_groupSearchBase\",
    \"searchBase\": \"$LDAP_SEARCHBASE\",
    \"url\": \"$LDAP_URL\",
    \"userDN\": \"$LDAP_USERDN\",
    \"userNameAttribute\": \"$LDAP_userNameAttribute\",
    \"userNameListFilter\": \"$LDAP_userNameListFilter\",
    \"userNameSearchFilter\": \"$LDAP_userNameSearchFilter\",
    \"userPassword\": \"$LDAP_USERPASSWORD\"
  }
  }" $API_SERVER/task/install_apim?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export APIM_IP='$APIM_IP'" >> install-devops-on-openstack.state
  echo "export LDAP_IP='$LDAP_IP'" >> install-devops-on-openstack.state
  echo "export LDAP_SEARCHBASE='$LDAP_SEARCHBASE'" >> install-devops-on-openstack.state
  echo "export LDAP_URL='$LDAP_URL'" >> install-devops-on-openstack.state
  echo "export LDAP_USERDN='$LDAP_USERDN'" >> install-devops-on-openstack.state
  echo "export LDAP_USERPASSWORD='$LDAP_USERPASSWORD'" >> install-devops-on-openstack.state
  echo "export LDAP_groupNameAttribute='$LDAP_groupNameAttribute'" >> install-devops-on-openstack.state
  echo "export LDAP_groupNameListFilter='$LDAP_groupNameListFilter'" >> install-devops-on-openstack.state
  echo "export LDAP_groupNameSearchFilter='$LDAP_groupNameSearchFilter'" >> install-devops-on-openstack.state
  echo "export LDAP_groupSearchBase='$LDAP_groupSearchBase'" >> install-devops-on-openstack.state
  echo "export LDAP_userNameAttribute='$LDAP_userNameAttribute'" >> install-devops-on-openstack.state
  echo "export LDAP_userNameListFilter='$LDAP_userNameListFilter'" >> install-devops-on-openstack.state
  echo "export LDAP_userNameSearchFilter='$LDAP_userNameSearchFilter'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_APIM='$RESP_INSTALL_APIM'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_APIM" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step12() {
  echo "# Step install_idp" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  IDP_IP=$(echo $RESP_CREATE_IDP_VM | jq '.artifact.idpvmendpoint' | sed 's/"//g')
  RESP_INSTALL_IDP=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\"
  },
  \"idp\": {
    \"idpvmendpoint\": \"$IDP_IP\"
  }
  }" $API_SERVER/task/install_idp?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export IDP_IP='$IDP_IP'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_IDP='$RESP_INSTALL_IDP'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_IDP" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step13() {
  echo "# Step install_nginx" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  NGINX_IP=$(echo $RESP_CREATE_NGINX_VM | jq '.artifact.nginxVMEndpoint' | sed 's/"//g')
  RESP_INSTALL_NGINX=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\"
  },
  \"nginx\": {
    \"nginxVMEndpoint\": \"$NGINX_IP\"
  }
  }" $API_SERVER/task/install_nginx?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export NGINX_IP='$NGINX_IP'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_NGINX='$RESP_INSTALL_NGINX'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_NGINX" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step14() {
  echo "# Step install_inception" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  INCEPTION_IP=$(echo $RESP_CREATE_INCEPTION_VM | jq '.artifact.inceptionVMEndpoint' | sed 's/"//g')
  RESP_INSTALL_INCEPTION=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\"
  },
  \"incepton\": {
    \"inceptionVMEndpoint\": \"$INCEPTION_IP\"
  }
  }" $API_SERVER/task/install_inception?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export INCEPTION_IP='$INCEPTION_IP'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_INCEPTION='$RESP_INSTALL_INCEPTION'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_INCEPTION" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step15() {
  echo "# Step install_microbosh" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  INCEPTION_IP=$(echo $RESP_CREATE_INCEPTION_VM | jq '.artifact.inceptionVMEndpoint' | sed 's/"//g')
  RESP_INSTALL_MICROBOSH=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSType\": \"openstack\",
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\",
    \"iaaSVMSSHKeyName\": \"$IaaSVMSSHKeyName\",
    \"openStackAPIKey\": \"$OpenStackAPIKey\",
    \"openStackAuthURL\": \"$OpenStackAuthURL\",
    \"openStackNetDNS\": \"$OpenStackNetDNS\",
    \"openStackNetGateway\": \"$OpenStackNetGateway\",
    \"openStackNetID\": \"$OpenStackNetID\",
    \"openStackNetIPPrivateMicrobosh\": \"$OpenStackNetIPPrivateMicrobosh\",
    \"openStackNetIPPublicMicrobosh\": \"$OpenStackNetIPPublicMicrobosh\",
    \"openStackNetRange\": \"$OpenStackNetRange\",
    \"openStackSecurityGroupID\": \"$OpenStackSecurityGroupID\",
    \"openStackTenantName\": \"$OpenStackTenantName\",
    \"openStackUserName\": \"$OpenStackUserName\"
  },
  \"incepton\": {
    \"inceptionVMEndpoint\": \"$INCEPTION_IP\"
  }
  }" $API_SERVER/task/install_microbosh?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export INCEPTION_IP='$INCEPTION_IP'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_MICROBOSH='$RESP_INSTALL_MICROBOSH'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_MICROBOSH" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step16() {
  echo "# Step install_cf" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  INCEPTION_IP=$(echo $RESP_CREATE_INCEPTION_VM | jq '.artifact.inceptionVMEndpoint' | sed 's/"//g')
  LDAP_SEARCHBASE=$(echo $RESP_INSTALL_LDAP | jq '.artifact.searchBase' | sed 's/"//g')
  LDAP_SEARCHFILTER=$(echo $RESP_INSTALL_LDAP | jq '.artifact.searchFilter' | sed 's/"//g')
  LDAP_URL=$(echo $RESP_INSTALL_LDAP | jq '.artifact.url' | sed 's/"//g')
  LDAP_USERDN=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userDN' | sed 's/"//g')
  LDAP_USERPASSWORD=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userPassword' | sed 's/"//g')
  RESP_INSTALL_CF=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSType\": \"openstack\",
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\",
    \"openStackNetCFIPEnd\": \"$OpenStackNetCFIPEnd\",
    \"openStackNetCFIPReservedEnd\": \"$OpenStackNetCFIPReservedEnd\",
    \"openStackNetCFIPReservedStart\": \"$OpenStackNetCFIPReservedStart\",
    \"openStackNetCFIPStart\": \"$OpenStackNetCFIPStart\",
    \"openStackNetDNS\": \"$OpenStackNetDNS\",
    \"openStackNetGateway\": \"$OpenStackNetGateway\",
    \"openStackNetID\": \"$OpenStackNetID\",
    \"openStackNetIPPrivateCFConsul\": \"$OpenStackNetIPPrivateCFConsul\",
    \"openStackNetIPPrivateCFEtcd\": \"$OpenStackNetIPPrivateCFEtcd\",
    \"openStackNetIPPrivateCFHaproxy\": \"$OpenStackNetIPPrivateCFHaproxy\",
    \"openStackNetIPPrivateCFNats\": \"$OpenStackNetIPPrivateCFNats\",
    \"openStackNetIPPrivateCFNfs\": \"$OpenStackNetIPPrivateCFNfs\",
    \"openStackNetIPPrivateCFPostgres\": \"$OpenStackNetIPPrivateCFPostgres\",
    \"openStackNetIPPrivateCFRouter\": \"$OpenStackNetIPPrivateCFRouter\",
    \"openStackNetIPPrivateCFRunner\": \"$OpenStackNetIPPrivateCFRunner\",
    \"openStackNetIPPrivateMicrobosh\": \"$OpenStackNetIPPrivateMicrobosh\",
    \"openStackNetIPPublicCF\": \"$OpenStackNetIPPublicCF\",
    \"openStackNetRange\": \"$OpenStackNetRange\"
  },
  \"incepton\": {
    \"inceptionVMEndpoint\": \"$INCEPTION_IP\"
  },
  \"ldap\": {
    \"searchBase\": \"$LDAP_SEARCHBASE\",
    \"searchFilter\": \"$LDAP_SEARCHFILTER\",
    \"url\": \"$LDAP_URL\",
    \"userDN\": \"$LDAP_USERDN\",
    \"userPassword\": \"$LDAP_USERPASSWORD\"
  }
  }" $API_SERVER/task/install_cf?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export INCEPTION_IP='$INCEPTION_IP'" >> install-devops-on-openstack.state
  echo "export LDAP_SEARCHBASE='$LDAP_SEARCHBASE'" >> install-devops-on-openstack.state
  echo "export LDAP_SEARCHFILTER='$LDAP_SEARCHFILTER'" >> install-devops-on-openstack.state
  echo "export LDAP_URL='$LDAP_URL'" >> install-devops-on-openstack.state
  echo "export LDAP_USERDN='$LDAP_USERDN'" >> install-devops-on-openstack.state
  echo "export LDAP_USERPASSWORD='$LDAP_USERPASSWORD'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_CF='$RESP_INSTALL_CF'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_CF" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

function step17() {
  echo "# Step install_ossapi" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  OSSAPI_IP=$(echo $RESP_CREATE_OSSAPI_VM | jq '.artifact.ossapiVMEndpoint' | sed 's/"//g')
  LDAP_SEARCHBASE=$(echo $RESP_INSTALL_LDAP | jq '.artifact.searchBase' | sed 's/"//g')
  LDAP_SEARCHFILTER=$(echo $RESP_INSTALL_LDAP | jq '.artifact.searchFilter' | sed 's/"//g')
  LDAP_URL=$(echo $RESP_INSTALL_LDAP | jq '.artifact.url' | sed 's/"//g')
  LDAP_USERDN=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userDN' | sed 's/"//g')
  LDAP_USERPASSWORD=$(echo $RESP_INSTALL_LDAP | jq '.artifact.userPassword' | sed 's/"//g')
  CF_API_URL=$(echo $RESP_INSTALL_CF | jq '.artifact.cfapiendpoint' | sed 's/"//g')
  CF_ADMIN_USER=$(echo $RESP_INSTALL_CF | jq '.artifact.cfadminUser' | sed 's/"//g')
  CF_ADMIN_PASS=$(echo $RESP_INSTALL_CF | jq '.artifact.cfadminPassword' | sed 's/"//g')
  RESP_INSTALL_OSSAPI=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\",
    \"openStackNetIPPrivateMicrobosh\": \"$OpenStackNetIPPrivateMicrobosh\"
  },
  \"ossapi\": {
    \"ossapiVMEndpoint\": \"$OSSAPI_IP\"
  },
  \"ldap\": {
    \"searchBase\": \"$LDAP_SEARCHBASE\",
    \"searchFilter\": \"$LDAP_SEARCHFILTER\",
    \"url\": \"$LDAP_URL\",
    \"userDN\": \"$LDAP_USERDN\",
    \"userPassword\": \"$LDAP_USERPASSWORD\"
  },
  \"cf\": {
    \"cfapiendpoint\": \"$CF_API_URL\",
    \"cfadminUser\": \"$CF_ADMIN_USER\",
    \"cfadminPassword\": \"$CF_ADMIN_PASS\"
  },
  \"microbosh\": {
    \"microboshAPIEndpoint\": \"https://$OpenStackNetIPPrivateMicrobosh:25555\",
    \"microboshAdminPassword\": \"admin\",
    \"microboshAdminUser\": \"admin\"
  }
  }" $API_SERVER/task/install_ossapi?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export OSSAPI_IP='$OSSAPI_IP'" >> install-devops-on-openstack.state
  echo "export LDAP_SEARCHBASE='$LDAP_SEARCHBASE'" >> install-devops-on-openstack.state
  echo "export LDAP_SEARCHFILTER='$LDAP_SEARCHFILTER'" >> install-devops-on-openstack.state
  echo "export LDAP_URL='$LDAP_URL'" >> install-devops-on-openstack.state
  echo "export LDAP_USERDN='$LDAP_USERDN'" >> install-devops-on-openstack.state
  echo "export LDAP_USERPASSWORD='$LDAP_USERPASSWORD'" >> install-devops-on-openstack.state
  echo "export CF_API_URL='$CF_API_URL'" >> install-devops-on-openstack.state
  echo "export CF_ADMIN_USER='$CF_ADMIN_USER'" >> install-devops-on-openstack.state
  echo "export CF_ADMIN_PASS='$CF_ADMIN_PASS'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_OSSAPI='$RESP_INSTALL_OSSAPI'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_OSSAPI" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}


function step18() {
  echo "# Step install_ossui" >> install-devops-on-openstack.state
  echo "# Started at $(date)" >> install-devops-on-openstack.state

  OSSUI_IP=$(echo $RESP_CREATE_OSSUI_VM | jq '.artifact.ossuiVMEndpoint' | sed 's/"//g')
  OSSAPI_URL=$(echo $RESP_INSTALL_OSSAPI | jq '.artifact.ossAPIEndpoint' | sed 's/"//g')
  RESP_INSTALL_OSSUI=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\"
  },
  \"ossui\": {
    \"ossuiVMEndpoint\": \"$OSSUI_IP\"
  },
  \"ossapi\": {
    \"ossAPIEndpoint\": \"$OSSAPI_URL\"
  }
  }" $API_SERVER/task/install_ossui?api_key=apiKey&api_key=apiKey)

  echo "# Finished at $(date)" >> install-devops-on-openstack.state
  echo "export OSSUI_IP='$OSSUI_IP'" >> install-devops-on-openstack.state
  echo "export OSSAPI_URL='$OSSAPI_URL'" >> install-devops-on-openstack.state
  echo "export RESP_INSTALL_OSSUI='$RESP_INSTALL_OSSUI'" >> install-devops-on-openstack.state
  echo "" >> install-devops-on-openstack.state

  message=$(echo "$RESP_INSTALL_OSSUI" | jq '.message')
  [ "$message" == "null" ] && return 0 || return 1
}

#main
	step0
	step1
	source install-devops-on-openstack.state && step2
	source install-devops-on-openstack.state && step3
	source install-devops-on-openstack.state && step4
	source install-devops-on-openstack.state && step5
	source install-devops-on-openstack.state && step6
	source install-devops-on-openstack.state && step7
	source install-devops-on-openstack.state && step8
	source install-devops-on-openstack.state && step10
	source install-devops-on-openstack.state && step11 
	source install-devops-on-openstack.state && step12
	source install-devops-on-openstack.state && step13
	source install-devops-on-openstack.state && step14
	source install-devops-on-openstack.state && step15
	source install-devops-on-openstack.state && step16
	source install-devops-on-openstack.state && step17
	source install-devops-on-openstack.state && step18

