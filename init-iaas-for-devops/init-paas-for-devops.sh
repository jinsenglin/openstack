#!/bin/bash

# api call sequences
# 	01. create_ldap_vm
# 	02. install_ldap
#	03. create_inception_vm
#	04. install_inception
#	05. install_microbosh
#	06. create_apim_vm
#	07. install_apim
#	08. create_idp_vm
#	09. install_idp
#	10. create_ossapi_vm
#	11. install_cf
#	12. install_ossapi

set -ex

function step0() {
  OpenStackImageID="412beaba-bb81-4e41-9f0e-afaf0a3aa3ad" # CHANGE ME when IaaS changed
  OpenStackNetID="26c8fc94-eb7f-47b5-9911-45ab66a72918" # CHANGE ME when IaaS changed
  IaaSVMSSHKeyContent="-----BEGIN RSA PRIVATE KEY-----|MIIEowIBAAKCAQEAlkohoIKUxEHPb/IuURYyDfohRpFOSadNZmy5QphBT8hBOVeE|ne1Wllv9Of/w1E9DxhZqOzsITs9jExyQcOfMUcb65goJA5cLPmZ1iTYSlvfgTQ8C|i1bRQ3J0HlAakJjmTCN/sUV3W05Z3JRTiqv3pIUGaf1BRfmEg4JVkZLBm9gFE3qi|E8xkWOyJn6wqtXcHFLpdqxSUHDgEQODV38SRdomyM1kaJBI/FxEzn3bXKuWMQx6x|5ThupVd6/SIzvF4rqr3K9sD3eq1GrygCk1vFr1nn3BuLvxmB/vbF5FN5AGGNx9P9|TxUyHeCfITiTDZDWwKL5S3Oms+QuItHBYzft7QIDAQABAoIBAD38z4fbtC6Kkluz|ASWSyQx4ybbIggjhB4yidXshP3b/ut9C2MEmvlsAEB8XEKcRFnwijKhnfdK7uTqN|wom/IcftEVlGdFdVul5/diUk91/rV0mRUlRUd7WhBIHoOjy/w+VNkwJ0C3nOhEP1|rct5iIgEEhQvT/fjpaN0Y4TKii6TthpkjiNnLSf2vmKowc9DFGU2ZnC0HDnbym2e|SWlKxz/l4QFD0ioA+biMcoV0i2qpp4A6i5W+2VsEYlv9kZJJaEaVEIjWoGxJABks|EKFjvyss9cQUHWDBGWmZ6gy+HjS96XxCdnMps73d6V3cjisSd5xyq1WZFdBMYGlk|h7lhquUCgYEAxqkzVOooLb5JVk/jMnH0gwdBHtp+eGMr+ZvYGMqRYTeonRxj8szz|CXyFvBbI/5YsYmGTwFt2m4YN5ObsSv0x7HKp8MgpDzlTDuDL5DPZkMYo5QNuv93d|jMLXgfCabDgNecnsGQkC+5yMt5JEGGShZzIw7zkptF41WjrAKgjlM/sCgYEAwarV|WwJTc762RVvb1K61bHCMLi70rEhRd8ezAqhrM7SZAKQqgcu2lxbTc82r/LG9lbbn|16vPL8/0YpdtoP+yQC9mNSN+B/RJO8qlVAxVjCemHaD/l/aTkad8wMv999DhF+Hy|9zCoGulzbhJU/mskncE+PyRm84FjUkP7RJSe2TcCgYEAhIGdJHlevUwb3H9CmoYZ|wj/Xdr3j92amkUIavEZ4+7BFPi4OmIeNX/l3tkI4ZQoEpsZQ58/Z59hdch145HfH|kd/VbC4F/QqOVPEp7heLeZ5C7qYAe+d/fAEF/7y9M4ubqW0+lmBFZhBAZ70ewGp2|ob9/lkC5iX4A9iMTw7XVM3sCgYBSt/zZGm06isKfbVS/yr+Cya+WKkgnLdxeJNW4|1Oa09vZC59ugBLrAXeeDFt3W2LP5Nl5gJ+oeqdvgIH2avpwL/jLRj49NJnIBL9Td|yUbgzi6NiS6iYZc2JyuJzZd0Oatq3/8+xXGHzR6YbQwQfwLsvpUvswSmDSW3BYJV|EIWokQKBgDXGuIvrcdVthYKREwGmskZkRtTy9/eEd1E6HFZ841DANublSsn0bWBu|9nqtlGu2Jp6nAmM4ppYCBjIKsjaCL3muCOrh3BKFE+MEztpmN+6Uqi9vrqoBeI9f|e+V5GNCWXCZ61BtjZGC+rXi/NhO5QM4AqjCBgktWGshz55ovdM6j|-----END RSA PRIVATE KEY-----" # CHANGE ME when IaaS changed

  OpenStackTenantName="devops"
  OpenStackUserName="devops"
  OpenStackAPIKey="devops"
  IaaSVMSSHKeyName="devops"
  OpenStackSecurityGroupID="devops"

  API_SERVER="http://10.5.50.134:9000" # CHANGE IT when platform-installer virtual machine changed
  OpenStackAuthURL="http://10.5.50.3:5000/v2.0" # CHANGE ME when IaaS changed
  OpenStackNetIPPublicMicrobosh="10.5.50.135" # CHANGE ME when IaaS changed
  OpenStackNetIPPublicCF="10.5.50.140" # CHANGE ME when IaaS changed

  IaaSVMSSHAccount="ubuntu"
  OpenStackNetDNS="8.8.8.8"
  OpenStackNetGateway="192.168.100.1"
  OpenStackNetIPPrivateMicrobosh="192.168.100.6"
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
  echo "# step1" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export RESP_CREATE_LDAP_VM='$RESP_CREATE_LDAP_VM'" >> init-paas-for-devops.state
}

function step2() {
  echo "# step2" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

  LDAP_IP=$(echo $RESP_CREATE_LDAP_VM | jq '.artifact.ldapvmendpoint' | sed 's/"//g')
  RESP_INSTALL_LDAP=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\"
  },
  \"ldap\": {
    \"ldapvmendpoint\": \"$LDAP_IP\"
  }
  }" $API_SERVER/task/install_ldap?api_key=apiKey&api_key=apiKey | sed 's/&amp;/\&/g')

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export LDAP_IP='$LDAP_IP'" >> init-paas-for-devops.state
  echo "export RESP_INSTALL_LDAP='$RESP_INSTALL_LDAP'" >> init-paas-for-devops.state
}

function step3() {
  echo "# step3" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export RESP_CREATE_INCEPTION_VM='$RESP_CREATE_INCEPTION_VM'" >> init-paas-for-devops.state
}

function step4() {
  echo "# step4" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export INCEPTION_IP='$INCEPTION_IP'" >> init-paas-for-devops.state
  echo "export RESP_INSTALL_INCEPTION='$RESP_INSTALL_INCEPTION'" >> init-paas-for-devops.state
}

function step5() {
  echo "# step5" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export INCEPTION_IP='$INCEPTION_IP'" >> init-paas-for-devops.state
  echo "export RESP_INSTALL_MICROBOSH='$RESP_INSTALL_MICROBOSH'" >> init-paas-for-devops.state
}

function step6() {
  echo "# step6" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export RESP_CREATE_APIM_VM='$RESP_CREATE_APIM_VM'" >> init-paas-for-devops.state
}

function step7() {
  echo "# step7" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export APIM_IP='$APIM_IP'" >> init-paas-for-devops.state
  echo "export LDAP_IP='$LDAP_IP'" >> init-paas-for-devops.state
  echo "export LDAP_SEARCHBASE='$LDAP_SEARCHBASE'" >> init-paas-for-devops.state
  echo "export LDAP_URL='$LDAP_URL'" >> init-paas-for-devops.state
  echo "export LDAP_USERDN='$LDAP_USERDN'" >> init-paas-for-devops.state
  echo "export LDAP_USERPASSWORD='$LDAP_USERPASSWORD'" >> init-paas-for-devops.state
  echo "export LDAP_groupNameAttribute='$LDAP_groupNameAttribute'" >> init-paas-for-devops.state
  echo "export LDAP_groupNameListFilter='$LDAP_groupNameListFilter'" >> init-paas-for-devops.state
  echo "export LDAP_groupNameSearchFilter='$LDAP_groupNameSearchFilter'" >> init-paas-for-devops.state
  echo "export LDAP_groupSearchBase='$LDAP_groupSearchBase'" >> init-paas-for-devops.state
  echo "export LDAP_userNameAttribute='$LDAP_userNameAttribute'" >> init-paas-for-devops.state
  echo "export LDAP_userNameListFilter='$LDAP_userNameListFilter'" >> init-paas-for-devops.state
  echo "export LDAP_userNameSearchFilter='$LDAP_userNameSearchFilter'" >> init-paas-for-devops.state
  echo "export RESP_INSTALL_APIM='$RESP_INSTALL_APIM'" >> init-paas-for-devops.state
}

function step8() {
  echo "# step8" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export RESP_CREATE_IDP_VM='$RESP_CREATE_IDP_VM'" >> init-paas-for-devops.state
}

function step9() {
  echo "# step9" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export IDP_IP='$IDP_IP'" >> init-paas-for-devops.state
  echo "export RESP_INSTALL_IDP='$RESP_INSTALL_IDP'" >> init-paas-for-devops.state
}

function step10() {
  echo "# step10" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export RESP_CREATE_OSSAPI_VM='$RESP_CREATE_OSSAPI_VM'" >> init-paas-for-devops.state
}

function step11() {
  echo "# step11" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

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

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export INCEPTION_IP='$INCEPTION_IP'" >> init-paas-for-devops.state
  echo "export LDAP_SEARCHBASE='$LDAP_SEARCHBASE'" >> init-paas-for-devops.state
  echo "export LDAP_SEARCHFILTER='$LDAP_SEARCHFILTER'" >> init-paas-for-devops.state
  echo "export LDAP_URL='$LDAP_URL'" >> init-paas-for-devops.state
  echo "export LDAP_USERDN='$LDAP_USERDN'" >> init-paas-for-devops.state
  echo "export LDAP_USERPASSWORD='$LDAP_USERPASSWORD'" >> init-paas-for-devops.state
  echo "export RESP_INSTALL_CF='$RESP_INSTALL_CF'" >> init-paas-for-devops.state
}

function step12() {
  echo "# step12" >> init-paas-for-devops.state
  echo "# $(date)" >> init-paas-for-devops.state

  OSSAPI_IP=$(echo $RESP_CREATE_OSSAPI_VM | jq '.artifact.ossapiVMEndpoint' | sed 's/"//g')
  RESP_INSTALL_OSSAPI=$(curl -X POST --header "Content-Type: application/json" --header "Accept: */*" -d "{
  \"iaas\": {
    \"iaaSVMSSHAccount\": \"$IaaSVMSSHAccount\",
    \"iaaSVMSSHKeyContent\": \"$IaaSVMSSHKeyContent\",
    \"openStackNetIPPrivateMicrobosh\": \"192.168.100.6\"
  },
  \"ossapi\": {
    \"ossapiVMEndpoint\": \"$OSSAPI_IP\"
  },
  \"ldap\": {
    \"searchBase\": \"ou=users,ou=system\",
    \"searchFilter\": \"uid={0}\",
    \"url\": \"ldap://192.168.100.4:10389\",
    \"userDN\": \"uid=admin,ou=system\",
    \"userPassword\": \"secret\"
  },
  \"cf\": {
    \"cfapiendpoint\": \"https://api.10.5.50.140.xip.io\",
    \"cfadminUser\": \"admin\",
    \"cfadminPassword\": \"cfadmin\"
  },
  \"microbosh\": {
    \"microboshAPIEndpoint\": \"https://192.168.100.6:25555\",
    \"microboshAdminPassword\": \"admin\",
    \"microboshAdminUser\": \"admin\"
  }
  }" $API_SERVER/task/install_ossapi?api_key=apiKey&api_key=apiKey)

  echo "# $(date)" >> init-paas-for-devops.state
  echo "export OSSAPI_IP='$OSSAPI_IP'" >> init-paas-for-devops.state
  echo "export RESP_INSTALL_OSSAPI='$RESP_INSTALL_OSSAPI'" >> init-paas-for-devops.state
}

#main
	step0
	#step1
	#source init-paas-for-devops.state && step2
	#source init-paas-for-devops.state && step3
	#source init-paas-for-devops.state && step4
	#source init-paas-for-devops.state && step5
	#source init-paas-for-devops.state && step6
	#source init-paas-for-devops.state && step7
	#source init-paas-for-devops.state && step8
	#source init-paas-for-devops.state && step9
	#source init-paas-for-devops.state && step10
	#source init-paas-for-devops.state && step11
	#source init-paas-for-devops.state && step12

