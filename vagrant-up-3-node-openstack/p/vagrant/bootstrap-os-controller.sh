#!/bin/bash

set -e

ENV_MGMT_NETWORK="10.0.0.0/24"
ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"
ENV_MGMT_OS_NETWORK_IP="10.0.0.21"
ENV_MGMT_OS_COMPUTE_IP="10.0.0.31"

ENV_TUNNEL_NETWORK="10.0.1.0/24"
ENV_TUNNEL_OS_CONTROLLER_IP="10.0.1.11"
ENV_TUNNEL_OS_NETWORK_IP="10.0.1.21"
ENV_TUNNEL_OS_COMPUTE_IP="10.0.1.31"

LOG=/tmp/provision.log
date | tee $LOG            # when:  Thu Aug 10 07:48:13 UTC 2017
whoami | tee -a $LOG       # who:   root
pwd | tee -a $LOG          # where: /home/vagrant

CACHE=/vagrant/cache
[ -d $CACHE ] || mkdir -p $CACHE 

ARCHIVE=/vagrant/archive
[ -d $ARCHIVE ] || mkdir -p $ARCHIVE

function use_public_apt_server() {
    apt install -y software-properties-common
    add-apt-repository cloud-archive:pike
    apt-get update && APT_UPDATED=true

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-packages.html
}

function use_local_apt_server() {
    cat > /etc/apt/sources.list <<DATA
deb http://192.168.240.3/ubuntu xenial main restricted
deb http://192.168.240.3/ubuntu xenial universe
deb http://192.168.240.3/ubuntu xenial multiverse
deb http://192.168.240.3/ubuntu xenial-updates main restricted
deb http://192.168.240.3/ubuntu xenial-updates universe
deb http://192.168.240.3/ubuntu xenial-updates multiverse
deb http://192.168.240.3/ubuntu xenial-security main restricted
deb http://192.168.240.3/ubuntu xenial-security universe
deb http://192.168.240.3/ubuntu xenial-security multiverse
deb http://192.168.240.3/ubuntu-cloud-archive xenial-updates/pike main
DATA

    rm -rf /var/lib/apt/lists/*
    echo 'APT::Get::AllowUnauthenticated "true";' > /etc/apt/apt.conf.d/99-use-local-apt-server
    apt-get update && APT_UPDATED=true
}

function each_node_must_resolve_the_other_nodes_by_name_in_addition_to_IP_address() {
    cat >> /etc/hosts <<DATA
$ENV_MGMT_OS_CONTROLLER_IP os-controller
$ENV_MGMT_OS_NETWORK_IP os-network
$ENV_MGMT_OS_COMPUTE_IP os-compute
DATA

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-networking.html
}

function install_utilities() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y jq sshpass crudini
}

function install_python() {
    PYTHON_VERSION=2.7.11-1
    PYTHON_PIP_VERSION=8.1.1-2ubuntu0.4
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y python=$PYTHON_VERSION python-pip=$PYTHON_PIP_VERSION
    apt-get install -y python python-pip
}

function install_ntp() {
    CHRONY_VERSION=2.1.1-1
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y chrony=$CHRONY_VERSION
    apt-get install -y chrony

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # To enable other nodes to connect
    echo "allow $ENV_MGMT_NETWORK" >> /etc/chrony/chrony.conf

    # Restart the NTP service
    service chrony restart

    # Verify operation
    chronyc sources

    # Log files
    # /var/log/chrony/measurements.log
    # /var/log/chrony/statistics.log
    # /var/log/chrony/tracking.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-ntp-controller.html
}

function install_sqldb() {
    MARIADB_SERVER_VERSION=10.0.31-0ubuntu0.16.04.2
    PYTHON_PYMSQL_VERSION=0.7.9-2~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y mariadb-server=$MARIADB_SERVER_VERSION python-pymysql=$PYTHON_PYMSQL_VERSION
    apt-get install -y mariadb-server python-pymysql

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Create and edit the /etc/mysql/mariadb.conf.d/99-openstack.cnf file
    # For development convenience, you can use 0.0.0.0 instead of the management IP address.
    cat > /etc/mysql/mariadb.conf.d/99-openstack.cnf <<DATA
[mysqld]
bind-address = $ENV_MGMT_OS_CONTROLLER_IP

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
DATA

    # Restart the database service
    service mysql restart

    # Secure the database service by running the mysql_secure_installation script
    # skipped (root@localhost with no password by default)

    # Log files
    # /var/log/mysql/error.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-sql-database.html
}

function install_mq() {
    RABBITMQ_SERVER_VERSION=3.5.7-1ubuntu0.16.04.2
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y rabbitmq-server=$RABBITMQ_SERVER_VERSION
    apt-get install -y rabbitmq-server

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Add the openstack user
    rabbitmqctl add_user openstack RABBIT_PASS

    # Permit configuration, write, and read access for the openstack user
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"

    # Log files
    # /var/log/rabbitmq/rabbit@ubuntu-xenial.log
    # /var/log/rabbitmq/rabbit@ubuntu-xenial-sasl.log
    # /var/log/rabbitmq/startup_err
    # /var/log/rabbitmq/startup_log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-messaging.html
}

function install_memcached() {
    MEMCACHED_VERSION=1.4.25-2ubuntu1.2
    PYTHON_MEMCACHE_VERSION=1.57-1
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y memcached=$MEMCACHED_VERSION python-memcache=$PYTHON_MEMCACHE_VERSION
    apt-get install -y memcached python-memcache

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Edit the /etc/memcached.conf file and configure the service to use the management IP address of the controller node.
    # For development convenience, you can use 0.0.0.0 instead of the management IP address.
    sed -i "s/-l 127.0.0.1/-l $ENV_MGMT_OS_CONTROLLER_IP/" /etc/memcached.conf

    # Restart the Memcached service
    service memcached restart

    # Log files
    # n/a

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-memcached.html
}

function install_openstack_cli() {
    PYTHON_OPENSTACKCLIENT_VERSION=3.8.1-0ubuntu3~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt install -y python-openstackclient=$PYTHON_OPENSTACKCLIENT_VERSION
    apt install -y python-openstackclient

    cat > /root/admin-openrc <<DATA
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://os-controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
DATA

    cat > /root/demo-openrc <<DATA
export OS_USERNAME=demo
export OS_PASSWORD=DEMO_PASS
export OS_PROJECT_NAME=demo
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://os-controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
DATA

}

function download_keystone() {
    KEYSTONE_VERSION=2:11.0.3-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y keystone=$KEYSTONE_VERSION
    apt-get install -y keystone
}

function configure_keystone() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Create the database
    mysql <<DATA
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'KEYSTONE_DBPASS';
DATA

    # Edit the /etc/keystone/keystone.conf file, [token] section
    sed -i "s|^#provider = fernet|provider = fernet|" /etc/keystone/keystone.conf

    # Edit the /etc/keystone/keystone.conf file, [database] section
    sed -i "s|^#connection = <None>|connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@os-controller/keystone|" /etc/keystone/keystone.conf

    # Populate the database
    su -s /bin/sh -c "keystone-manage db_sync" keystone

    # Initialize Fernet key repositories
    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

    # Bootstrap the Identity service
    keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
                              --bootstrap-admin-url http://os-controller:35357/v3/ \
                              --bootstrap-internal-url http://os-controller:5000/v3/ \
                              --bootstrap-public-url http://os-controller:5000/v3/ \
                              --bootstrap-region-id RegionOne

    # Edit the /etc/apache2/apache2.conf file and configure the ServerName option to reference the controller node
    echo "ServerName os-controller" >> /etc/apache2/apache2.conf 

    # Restart the Apache service
    service apache2 restart

    # Remove the default SQLite database
    rm -f /var/lib/keystone/keystone.db

    # Now can use admin token
    source /root/admin-openrc
    openstack token issue

    # Now can use admin token to create more domains, projects, users, and roles
    openstack project create --domain default --description "Service Project" service
    openstack project create --domain default --description "Demo Project" demo
    openstack user create --domain default --password DEMO_PASS demo
    openstack role create user
    openstack role add --project demo --user demo user

    # For security reasons, disable the temporary authentication token mechanism
    # Edit the /etc/keystone/keystone-paste.ini file and remove admin_token_auth from the [pipeline:public_api], [pipeline:admin_api], and [pipeline:api_v3] sections.
    # skipped

    # Log files
    # /var/log/keystone/keystone-manage.log
    # /var/log/apache2/keystone_access.log
    # /var/log/apache2/keystone.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/keystone.html
}

function download_glance() {
    GLANCE_VERSION=2:14.0.0-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y glance=$GLANCE_VERSION
    apt-get install -y glance
}

function configure_glance() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Create the database
    mysql <<DATA
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'GLANCE_DBPASS';
DATA

    # Create the user
    source /root/admin-openrc
    openstack user create --domain default --password GLANCE_PASS glance

    # Associate the user with the admin role and the service project
    source /root/admin-openrc
    openstack role add --project service --user glance admin

    # Create the service entity
    source /root/admin-openrc
    openstack service create --name glance --description "OpenStack Image" image

    # Create the service api endpoint
    source /root/admin-openrc
    openstack endpoint create --region RegionOne image public http://os-controller:9292
    openstack endpoint create --region RegionOne image internal http://os-controller:9292
    openstack endpoint create --region RegionOne image admin http://os-controller:9292

    # Edit the /etc/glance/glance-api.conf file, [database] section
    sed -i "s|^#connection = <None>|connection = mysql+pymysql://glance:GLANCE_DBPASS@os-controller/glance|" /etc/glance/glance-api.conf

    # Edit the /etc/glance/glance-api.conf file, [keystone_authtoken] section
    echo -e "auth_uri = http://os-controller:5000\nauth_url = http://os-controller:35357\nmemcached_servers = os-controller:11211\nauth_type = password\nproject_domain_name = Default\nuser_domain_name = Default\nproject_name = service\nusername = glance\npassword = GLANCE_PASS\n" | sed -i "/^\[keystone_authtoken\]/ r /dev/stdin" /etc/glance/glance-api.conf

    # Edit the /etc/glance/glance-api.conf file, [paste_deploy] section
    sed -i "s|#flavor = keystone|flavor = keystone|" /etc/glance/glance-api.conf

    # Edit the /etc/glance/glance-api.conf file, [glance_store] section
    echo -e "stores = file,http\ndefault_store = file\nfilesystem_store_datadir = /var/lib/glance/images/\n" | sed -i "/^\[glance_store\]/ r /dev/stdin" /etc/glance/glance-api.conf

    # Edit the /etc/glance/glance-registry.conf file, [database] section
    sed -i "s|^#connection = <None>|connection = mysql+pymysql://glance:GLANCE_DBPASS@os-controller/glance|" /etc/glance/glance-registry.conf

    # Edit the /etc/glance/glance-registry.conf file, [keystone_authtoken] section
    echo -e "auth_uri = http://os-controller:5000\nauth_url = http://os-controller:35357\nmemcached_servers = os-controller:11211\nauth_type = password\nproject_domain_name = Default\nuser_domain_name = Default\nproject_name = service\nusername = glance\npassword = GLANCE_PASS\n" | sed -i "/^\[keystone_authtoken\]/ r /dev/stdin" /etc/glance/glance-registry.conf

    # Edit the /etc/glance/glance-registry.conf file, [paste_deploy] section
    sed -i "s|#flavor = keystone|flavor = keystone|" /etc/glance/glance-registry.conf

    # Populate the database
    su -s /bin/sh -c "glance-manage db_sync" glance

    # Restart the Image services
    service glance-registry restart
    service glance-api restart

    # Now can use admin token to create images
    [ -f $CACHE/cirros-0.3.4-x86_64-disk.img ] || \
    wget -q http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img -O $CACHE/cirros-0.3.4-x86_64-disk.img

    source /root/admin-openrc
    for i in $(seq 1 3); do sleep 1; openstack image list && break; done # at most retry 3 times to ensure image api ready, and wait 1 second between each retry.
    openstack image create "cirros" --file $CACHE/cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
    openstack image list

    # Log files
    # /var/log/glance/glance-api.log
    # /var/log/glance/glance-registry.log    

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/glance.html
}

function download_neutron() {
    NEUTRON_SERVER_VERSION=2:10.0.3-0ubuntu1~cloud0
    NEUTRON_PLUGIN_ML2_VERSION=2:10.0.3-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt install -y neutron-server=$NEUTRON_SERVER_VERSION \
    #               neutron-plugin-ml2=$NEUTRON_PLUGIN_ML2_VERSION
    apt install -y neutron-server \
                   neutron-plugin-ml2
}

function configure_neutron() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Create the database
    mysql <<DATA
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'NEUTRON_DBPASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'NEUTRON_DBPASS';
DATA

    # Create the user
    source /root/admin-openrc
    openstack user create --domain default --password NEUTRON_PASS neutron

    # Associate the user with the admin role and the service project
    source /root/admin-openrc
    openstack role add --project service --user neutron admin

    # Create the service entity
    source /root/admin-openrc
    openstack service create --name neutron --description "OpenStack Networking" network

    # Create the service api endpoint
    source /root/admin-openrc
    openstack endpoint create --region RegionOne network public http://os-controller:9696
    openstack endpoint create --region RegionOne network internal http://os-controller:9696
    openstack endpoint create --region RegionOne network admin http://os-controller:9696

    # Edit the /etc/neutron/neutron.conf file, [database] section
    sed -i "s|^connection = sqlite.*|connection = mysql+pymysql://neutron:NEUTRON_DBPASS@os-controller/neutron|" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a service_plugins = router" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a allow_overlapping_ips = True" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a transport_url = rabbit://openstack:RABBIT_PASS@os-controller" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a auth_strategy = keystone" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a notify_nova_on_port_status_changes = True" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a notify_nova_on_port_data_changes = True" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [keystone_authtoken] section
    echo -e "auth_uri = http://os-controller:5000\nauth_url = http://os-controller:35357\nmemcached_servers = os-controller:11211\nauth_type = password\nproject_domain_name = Default\nuser_domain_name = Default\nproject_name = service\nusername = neutron\npassword = NEUTRON_PASS\n" | sed -i "/^\[keystone_authtoken\]/ r /dev/stdin" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [nova] section
    echo -e "auth_url = http://os-controller:35357\nauth_type = password\nproject_domain_name = Default\nuser_domain_name = Default\nregion_name = RegionOne\nproject_name = service\nusername = nova\npassword = NOVA_PASS\n" | sed -i "/^\[nova\]/ r /dev/stdin" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file, [ml2] section
    sed -i "/^\[ml2\]$/ a type_drivers = flat,vlan,vxlan" /etc/neutron/plugins/ml2/ml2_conf.ini
    sed -i "/^\[ml2\]$/ a tenant_network_types = vxlan" /etc/neutron/plugins/ml2/ml2_conf.ini
    sed -i "/^\[ml2\]$/ a mechanism_drivers = openvswitch,l2population" /etc/neutron/plugins/ml2/ml2_conf.ini
    sed -i "/^\[ml2\]$/ a extension_drivers = port_security" /etc/neutron/plugins/ml2/ml2_conf.ini

    # Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file, [ml2_type_flat] section
    sed -i "/^\[ml2_type_flat\]$/ a flat_networks = external" /etc/neutron/plugins/ml2/ml2_conf.ini

    # Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file, [ml2_type_vxlan] section
    sed -i "/^\[ml2_type_vxlan\]$/ a vni_ranges = 1:1000" /etc/neutron/plugins/ml2/ml2_conf.ini

    # Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file, [securitygroup] section
    sed -i "/^\[securitygroup\]$/ a enable_ipset = True" /etc/neutron/plugins/ml2/ml2_conf.ini

    # Populate the database
    su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

    # Restart the Networking services
    service neutron-server restart

    # Verify operation
    #source /root/admin-openrc
    #neutron ext-list
    #openstack network agent list

    # Log files
    # /var/log/neutron/neutron-server.log

    # References
    # https://docs.openstack.org/newton/install-guide-ubuntu/neutron-controller-install.html
    # https://docs.openstack.org/newton/install-guide-ubuntu/neutron-controller-install-option2.html
    # https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#controller-node

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/neutron-controller-install.html
    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/neutron-controller-install-option2.html
    # This reference is for 2-nodes deployment (one controller, one compute), but we need 3-nodes deployment (one controller, one network, one compute).
    # This reference uses neutron-linuxbridge-agent, but we need neutron-openvswitch-agent.
    # This reference uses FLAT provider networks.
    # This reference uses VXLAN self-service networks.
    # `apt-get install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent` # for controller node
    # `apt-get install neutron-linuxbridge-agent` # for compute node

    # Reference https://docs.openstack.org/neutron/pike/admin/deploy-ovs-selfservice.html
    # This reference is for pike version, but we need newton version.
    # This reference is for 3-nodes deployment.
    # This reference uses neutron-openvswitch-agent.
    # This reference is for VXLAN self-service networks.

    # Reference http://www.unixarena.com/2015/10/openstack-configure-network-service-neutron-controller-part-6.html
    # Reference http://www.unixarena.com/2015/10/openstack-configure-neutron-on-network-node-part-7.html
    # Reference http://www.unixarena.com/2015/10/openstack-configure-neutron-on-compute-node-part-8.html
    # This reference is for 3-nodes deployment.
    # This reference uses neutron-openvswitch-agent.
    # This reference uses GRE self-service networks, but we need VXLAN version.
    # `apt-get install neutron-server neutron-plugin-ml2` # for controller node
    # `apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent` # for network node
    # `apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent` # for compute node

    # Reference https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/ *****
    # This reference is for 3-nodes deployment.
    # This reference uses neutron-openvswitch-agent.
    # This reference uses VXLAN self-service networks.
    # `apt-get install neutron-server neutron-plugin-ml2` # for controller node
    # `apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent` # for network node
    # `apt-get install neutron-plugin-openvswitch-agent` # for compute node

    # Reference http://www.madorn.com/virtualbox-liberty-install-guide.html#.WZgT85Og_BI
    # This reference details how to use VirtualBox network adapters for OpenStack installation
    # Create a "NAT Networks" named management for management network, CIDR 10.0.0.0/24. Check "Supports DHCP"
    # -> attach VM network adapter1 to this network.
    # Create a "NAT Networks" named public for public network, CIDR 203.0.113.0/24. Uncheck "Supports DHCP". The GW will be 203.0.113.1
    # -> attach VM network adapter2 to this network.
    # No mention about "Promiscuous mode".

    # Reference http://www.innervoice.in/blogs/2015/06/14/virtualbox-networking-settings-for-openstack/
    # This reference details how to use VirtualBox network adapters for OpenStack installation
    # This reference is for 2-nodes deployment.
    # Attach VM network adapter1 to "HOST-ONLY" for management network.
    # Attach VM network adapter2 to "HOST-ONLY" for public network.
    # -> "For external network Host-only is sufficient. If the OpenStack VMs are able to reach the Host, then the objective of external network is achieved. But you can also use NAT."
    # Attach VM network adapter3 to "NAT". (Additional interface)
    # -> "This adapter provides Internet access to the nodes to download packages etc."
    # -> "But the VM instances also need Internet access. So I recommend an additional interface of type NAT just to accomplish that."
    # "Tip: it is important to enable Promiscuous mode on data network".

    # Reference https://developer.ibm.com/recipes/tutorials/newton-openstack-installation-on-centos7-inside-the-virtualbox/
    # This reference details how to use VirtualBox network adapters for OpenStack installation
    # This reference is for 2-nodes deployment.
    # Attach VM network adapter1 to "HOST-ONLY" for management network.
    # Attach VM network adapter2 to "NAT" for public network.
    # No mention about "Promiscuous mode".

    # https://uksysadmin.wordpress.com/2011/02/17/running-openstack-under-virtualbox-a-complete-guide/
    # This reference details how to use VirtualBox network adapters for OpenStack installation
    # This reference is for 1-nodes deployment.
    # Create a "HOST-ONLY Networks" named public for public network, CIDR 172.241.0.100/28. Uncheck "Supports DHCP".
    # -> attach VM network adapter1 to this network.
    # -> "Access from host running VirtualBox only (so useful for development/proof of concept)"
    # attach VM network adapter2 to "NAT".
    # -> "This will provide the default route to allow the VM to access the internet to get the updates, OpenStack scripts and software"

    # http://godleon.blogspot.tw/2014/10/openstack-ubuntu-1404-5-networking.html
    # This reference is for 3-nodes deployment.
    # Use VMware instead of VirtualBox.
    # Use "Promiscuous mode" on public network.

    # References
    # [ ns ] [ veth ] http://cizixs.com/2017/02/10/network-virtualization-network-namespace
    # [ ns ] [ ovs ] http://www.rendoumi.com/yong-open-vswitch-de-nei-bu-duan-kou-lian-jie-liang-ge-namespace/
    # [ ns ] [ ovs ] [ veth ] http://plasmixs.github.io/network-namespaces-ovs.html
    # [ neutron ] [ ovs ] https://docs.openstack.org/liberty/networking-guide/scenario-classic-ovs.html
    # [ ns ] [ ovs ] [ veth ] vs. [ ns ] [ ovs ] [ port ] http://www.opencloudblog.com/?p=66
    # [ ovs ] [ patch] https://blog.scottlowe.org/2012/11/27/connecting-ovs-bridges-with-patch-ports/
}

function download_nova() {
    NOVA_API_VERSION=2:15.0.7-0ubuntu1~cloud0
    NOVA_CONDUCTOR_VERSION=2:15.0.7-0ubuntu1~cloud0
    NOVA_CONSOLEAUTH_VERSION=2:15.0.7-0ubuntu1~cloud0
    NOVA_NOVNCPROXY_VERSION=2:15.0.7-0ubuntu1~cloud0
    NOVA_SCHEDULER_VERSION=2:15.0.7-0ubuntu1~cloud0
    NOVA_PLACEMENT_API_VERSION=2:15.0.7-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y nova-api=$NOVA_API_VERSION nova-conductor=$NOVA_CONDUCTOR_VERSION nova-consoleauth=$NOVA_CONSOLEAUTH_VERSION nova-novncproxy=$NOVA_NOVNCPROXY_VERSION nova-scheduler=$NOVA_SCHEDULER_VERSION nova-placement-api=$NOVA_PLACEMENT_API_VERSION
    apt-get install -y nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler nova-placement-api
}

function configure_nova() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Create the database
    mysql <<DATA
CREATE DATABASE nova_api;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';
CREATE DATABASE nova_cell0;
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';
DATA

    # Create the user
    source /root/admin-openrc
    openstack user create --domain default --password NOVA_PASS nova
    openstack user create --domain default --password PLACEMENT_PASS placement

    # Associate the user with the admin role and the service project
    source /root/admin-openrc
    openstack role add --project service --user nova admin
    openstack role add --project service --user placement admin

    # Create the service entity
    source /root/admin-openrc
    openstack service create --name nova --description "OpenStack Compute" compute
    openstack service create --name placement --description "Placement API" placement

    # Create the service api endpoint
    source /root/admin-openrc
    openstack endpoint create --region RegionOne compute public http://os-controller:8774/v2.1/%\(tenant_id\)s
    openstack endpoint create --region RegionOne compute internal http://os-controller:8774/v2.1/%\(tenant_id\)s
    openstack endpoint create --region RegionOne compute admin http://os-controller:8774/v2.1/%\(tenant_id\)s
    openstack endpoint create --region RegionOne placement public http://os-controller:8778
    openstack endpoint create --region RegionOne placement internal http://os-controller:8778
    openstack endpoint create --region RegionOne placement admin http://os-controller:8778

    # Edit the /etc/nova/nova.conf file, [api_database] section
    sed -i "/^connection=/ d" /etc/nova/nova.conf
    sed -i "/^\[api_database\]$/ a connection = mysql+pymysql://nova:NOVA_DBPASS@os-controller/nova_api" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [database] section
    sed -i "/^connection=/ d" /etc/nova/nova.conf
    sed -i "/^\[database\]$/ a connection = mysql+pymysql://nova:NOVA_DBPASS@os-controller/nova" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a transport_url = rabbit://openstack:RABBIT_PASS@os-controller" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a auth_strategy = keystone" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a my_ip = $ENV_MGMT_OS_CONTROLLER_IP" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a use_neutron = True" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a firewall_driver = nova.virt.firewall.NoopFirewallDriver" /etc/nova/nova.conf
    sed -i "/^log-dir=/ d" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [keystone_authtoken] section
    cat >> /etc/nova/nova.conf <<DATA

[keystone_authtoken]
auth_uri = http://os-controller:5000
auth_url = http://os-controller:35357
memcached_servers = os-controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = NOVA_PASS
DATA

    # Edit the /etc/nova/nova.conf file, [vnc] section
    cat >> /etc/nova/nova.conf <<DATA

[vnc]
vncserver_listen = $ENV_MGMT_OS_CONTROLLER_IP
vncserver_proxyclient_address = $ENV_MGMT_OS_CONTROLLER_IP
DATA

    # Edit the /etc/nova/nova.conf file, [glance] section
    cat >> /etc/nova/nova.conf <<DATA

[glance]
api_servers = http://os-controller:9292
DATA

    # Edit the /etc/nova/nova.conf file, [oslo_concurrency] section
    sed -i "/^lock_path=/ d" /etc/nova/nova.conf
    sed -i "/^\[oslo_concurrency\]$/ a lock_path = /var/lib/nova/tmp" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [placement] section
    sed -i "s|^os_region_name = openstack|os_region_name = RegionOne|" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a project_domain_name = Default" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a project_name = service" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a auth_type = password" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a user_domain_name = Default" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a auth_url = http://os-controller:35357/v3" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a username = placement" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a password = PLACEMENT_PASS" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [scheduler] section
    sed -i "s|^#discover_hosts_in_cells_interval = -1|discover_hosts_in_cells_interval = 10|" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [neutron] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#controller-node
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    cat >> /etc/nova/nova.conf <<DATA

[neutron]
url = http://os-controller:9696
auth_url = http://os-controller:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = NEUTRON_PASS
service_metadata_proxy = True
metadata_proxy_shared_secret = METADATA_SECRET
DATA

    # Populate the database
    su -s /bin/sh -c "nova-manage api_db sync" nova
    su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
    su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
    su -s /bin/sh -c "nova-manage db sync" nova
    nova-manage cell_v2 list_cells

    # Restart the Compute services
    service nova-api restart
    service nova-consoleauth restart
    service nova-scheduler restart
    service nova-conductor restart
    service nova-novncproxy restart

    # Log files
    # /var/log/nova/nova-api.log
    # /var/log/nova/nova-conductor.log
    # /var/log/nova/nova-consoleauth.log
    # /var/log/nova/nova-novncproxy.log
    # /var/log/nova/nova-scheduler.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/nova.html
}

function download_lbaas() {
    NEUTRON_LBAAS_VERSION=2:10.0.1-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt install -y python-neutron-lbaas=$NEUTRON_LBAAS_VERSION
    apt install -y python-neutron-lbaas=

    # Reference https://docs.openstack.org/ocata/networking-guide/config-lbaas.html
}

function configure_lbaas() {
    # Edit the /etc/neutron/neutron.conf file, [DEFAULT] section
    sed -i "s|^service_plugins = router|service_plugins = router,lbaasv2|" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [service_auth] section
    cat >> /etc/neutron/neutron.conf <<DATA

[service_auth]
auth_url = http://os-controller:5000/v3
auth_version = 3
admin_user = admin
admin_password = ADMIN_PASS
admin_tenant_name = admin
admin_user_domain = Default
admin_project_domain = Default
DATA

    # Edit the /etc/neutron/neutron_lbaas.conf, [service_providers] section
    sed -i "/^\[service_providers\]$/ a service_provider = LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default" /etc/neutron/neutron_lbaas.conf

    # Edit the /etc/neutron/neutron_lbaas.conf, [service_auth] section
    sed -i "/^\[service_auth\]$/ a auth_url = http://os-controller:5000/v3" /etc/neutron/neutron_lbaas.conf
    sed -i "/^\[service_auth\]$/ a auth_version = 3" /etc/neutron/neutron_lbaas.conf
    sed -i "/^\[service_auth\]$/ a admin_user = admin" /etc/neutron/neutron_lbaas.conf
    sed -i "/^\[service_auth\]$/ a admin_password = ADMIN_PASS" /etc/neutron/neutron_lbaas.conf
    sed -i "/^\[service_auth\]$/ a admin_tenant_name = admin" /etc/neutron/neutron_lbaas.conf
    sed -i "/^\[service_auth\]$/ a admin_user_domain = Default" /etc/neutron/neutron_lbaas.conf
    sed -i "/^\[service_auth\]$/ a admin_project_domain = Default" /etc/neutron/neutron_lbaas.conf

    # Populate the database
    neutron-db-manage --subproject neutron-lbaas --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head

    # Restart the Networking services
    service neutron-server restart

    # Reference https://docs.openstack.org/ocata/networking-guide/config-lbaas.html
}

function archive_deb_pkg_list() {
    apt list --installed > $ARCHIVE/os-controller/apt/selection.txt
}

function archive_etc_tarball() {
    tar -czf $ARCHIVE/os-controller/etc.tgz /etc
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download)
                #use_local_apt_server
                use_public_apt_server
                each_node_must_resolve_the_other_nodes_by_name_in_addition_to_IP_address
                install_utilities
                install_python
                install_ntp
                install_sqldb
                install_mq
                install_memcached
                install_openstack_cli
                download_keystone
                download_glance
                download_nova
                download_neutron
#                download_lbaas
                archive_deb_pkg_list
                ;;
            configure)
                configure_keystone
                configure_glance
                configure_nova
                configure_neutron
#                configure_lbaas
                archive_etc_tarball
                ;;
            *)
                echo "unknown mode"
                ;;
        esac
        shift
    done
    echo done
}
main $@
