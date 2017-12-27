#!/bin/bash

set -e

ENV_MGMT_NETWORK="10.0.0.0/24"
ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"
ENV_MGMT_OS_NETWORK_IP="10.0.0.21"
ENV_MGMT_OS_COMPUTE_IP="10.0.0.31"
ENV_MGMT_ODL_CONTROLLER_IP="10.0.0.41"
ENV_MGMT_K8S_MASTER_IP="10.0.0.51"

ENV_TUNNEL_NETWORK="10.0.1.0/24"
ENV_TUNNEL_OS_CONTROLLER_IP="10.0.1.11"
ENV_TUNNEL_OS_NETWORK_IP="10.0.1.21"
ENV_TUNNEL_OS_COMPUTE_IP="10.0.1.31"
ENV_TUNNEL_ODL_CONTROLLER_IP="10.0.1.41"
ENV_TUNNEL_K8S_MASTER_IP="10.0.1.51"

LOG=/tmp/provision.log
date | tee $LOG            # when:  Thu Aug 10 07:48:13 UTC 2017
whoami | tee -a $LOG       # who:   root
pwd | tee -a $LOG          # where: /home/vagrant

CACHE=/vagrant/cache
[ -d $CACHE ] || mkdir -p $CACHE 

function use_public_apt_server() {
    apt install -y software-properties-common
    add-apt-repository cloud-archive:ocata
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
deb http://192.168.240.3/ubuntu-cloud-archive xenial-updates/ocata main
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
$ENV_MGMT_ODL_CONTROLLER_IP odl-controller
$ENV_MGMT_K8S_MASTER_IP k8s-master
DATA

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-networking.html
}

function install_utilities() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y crudini
}

function install_python() {
    PYTHON_VERSION=2.7.11-1
    PYTHON_PIP_VERSION=8.1.1-2ubuntu0.4
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y python=$PYTHON_VERSION python-pip=$PYTHON_PIP_VERSION
    #apt-get install -y python python-pip
}

function install_ntp() {
    CHRONY_VERSION=2.1.1-1
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y chrony=$CHRONY_VERSION
    #apt-get install -y chrony

    # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # ## # # # # # # # #

    # To connect to the os-controller node
    sed -i "s/^pool /#pool /g" /etc/chrony/chrony.conf
    sed -i "s/^server /#server /g" /etc/chrony/chrony.conf
    echo "server os-controller iburst" >> /etc/chrony/chrony.conf

    # Restart the NTP service
    service chrony restart

    # Verify operation
    chronyc sources

    # Log files
    # /var/log/chrony/measurements.log
    # /var/log/chrony/statistics.log
    # /var/log/chrony/tracking.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-ntp-other.html
}

function download_nova() {
    NOVA_COMPUTE_VERSION=2:15.0.7-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y nova-compute=$NOVA_COMPUTE_VERSION
    #apt-get install -y nova-compute
}

function configure_nova() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Edit the /etc/nova/nova.conf file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a transport_url = rabbit://openstack:RABBIT_PASS@os-controller" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a auth_strategy = keystone" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a my_ip = $ENV_MGMT_OS_COMPUTE_IP" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a use_neutron = True" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a firewall_driver = nova.virt.firewall.NoopFirewallDriver" /etc/nova/nova.conf

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
enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $ENV_MGMT_OS_COMPUTE_IP
novncproxy_base_url = http://os-controller:6080/vnc_auto.html
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

    # Edit the /etc/nova/nova.conf file, [neutron] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
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
DATA

    # Edit the /etc/nova/nova-compute.conf file, [libvirt] section
    sed -i "/^virt_type=/ d" /etc/nova/nova-compute.conf
    sed -i "/^\[libvirt\]$/ a virt_type = qemu" /etc/nova/nova-compute.conf

    # Restart the Compute service
    service nova-compute restart

    # Log files
    # /var/log/nova/nova-compute.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/nova-compute-install.html
}

function download_neutron() {
    NEUTRON_PLUGIN_ML2_VERSION=2:10.0.3-0ubuntu1~cloud0
    NEUTRON_OPENVSWITCH_AGENT_VERSION=2:10.0.3-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt install -y neutron-plugin-ml2=$NEUTRON_PLUGIN_ML2_VERSION \
                   neutron-openvswitch-agent=$NEUTRON_OPENVSWITCH_AGENT_VERSION
#    apt install -y neutron-plugin-ml2 \
#                   neutron-openvswitch-agent
}

function configure_neutron() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Edit the /etc/sysctl.conf
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "$ a net.ipv4.conf.all.rp_filter = 0" /etc/sysctl.conf
    sed -i "$ a net.ipv4.conf.default.rp_filter = 0" /etc/sysctl.conf
    sed -i "$ a net.bridge.bridge-nf-call-iptables = 1" /etc/sysctl.conf
    sed -i "$ a net.bridge.bridge-nf-call-ip6tables = 1" /etc/sysctl.conf
    sysctl -p

    # Edit the /etc/neutron/neutron.conf file, [database] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "s|^connection = |#connection = |" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a service_plugins = router" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a allow_overlapping_ips = True" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a transport_url = rabbit://openstack:RABBIT_PASS@os-controller" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a auth_strategy = keystone" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [keystone_authtoken] section
    echo -e "auth_uri = http://os-controller:5000\nauth_url = http://os-controller:35357\nmemcached_servers = os-controller:11211\nauth_type = password\nproject_domain_name = Default\nuser_domain_name = Default\nproject_name = service\nusername = neutron\npassword = NEUTRON_PASS\n" | sed -i "/^\[keystone_authtoken\]/ r /dev/stdin" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [ovs] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "/^\[ovs\]$/ a local_ip = $ENV_TUNNEL_OS_COMPUTE_IP" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [agent] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "/^\[agent\]$/ a tunnel_types = vxlan" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[agent\]$/ a l2_population = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[agent\]$/ a prevent_arp_spoofing = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [securitygroup] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "/^\[securitygroup\]$/ a enable_security_group = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[securitygroup\]$/ a firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Restart the Networking services
    service openvswitch-switch restart
    service neutron-openvswitch-agent restart

    # Log files
    # /var/log/neutron/neutron-openvswitch-agent.log
    # /var/log/neutron/neutron-ovs-cleanup.log
    # /var/log/openvswitch/ovsdb-server.log
    # /var/log/openvswitch/ovs-vswitchd.log

    # References
    # https://docs.openstack.org/newton/install-guide-ubuntu/neutron-compute-install.html
    # https://docs.openstack.org/newton/install-guide-ubuntu/neutron-compute-install-option2.html
    # https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    # https://www.centos.bz/2012/04/linux-sysctl-conf/
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
                download_nova
                download_neutron
                ;;
            configure)
                configure_nova
                configure_neutron
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
