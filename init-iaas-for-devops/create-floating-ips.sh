#!/bin/bash

set -ex

# create floating ip for micrbobosh
	export MICROBOSH_FLOATING_IP=$(nova floating-ip-create | sed -n '4 p' | awk '{print $2}')
	echo "export MICROBOSH_FLOATING_IP=$MICROBOSH_FLOATING_IP" >> create-floating-ips.state
	
# create floating ip for cloudfoundry
	export CF_FLOATING_IP=$(nova floating-ip-create | sed -n '4 p' | awk '{print $2}')
	echo "export CF_FLOATING_IP=$CF_FLOATING_IP" >> create-floating-ips.state
	
# create floating ip for apim (option)
	export APIM_FLOATING_IP=$(nova floating-ip-create | sed -n '4 p' | awk '{print $2}')
	echo "export APIM_FLOATING_IP=$APIM_FLOATING_IP" >> create-floating-ips.state
	
# create floating ip for idp (option)
	export IDP_FLOATING_IP=$(nova floating-ip-create | sed -n '4 p' | awk '{print $2}')
	echo "export IDP_FLOATING_IP=$IDP_FLOATING_IP" >> create-floating-ips.state
	
# create floating ip for ldap (option)
	export LDAP_FLOATING_IP=$(nova floating-ip-create | sed -n '4 p' | awk '{print $2}')
	echo "export LDAP_FLOATING_IP=$LDAP_FLOATING_IP" >> create-floating-ips.state
	
# create floating ip for ossapi (option)
	export OSSAPI_FLOATING_IP=$(nova floating-ip-create | sed -n '4 p' | awk '{print $2}')
	echo "export OSSAPI_FLOATING_IP=$OSSAPI_FLOATING_IP" >> create-floating-ips.state
	
