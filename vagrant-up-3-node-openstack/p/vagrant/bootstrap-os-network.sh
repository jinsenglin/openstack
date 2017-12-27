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

ENV_PUBLIC_INTERFACE="enp0s10"

LOG=/tmp/provision.log
date | tee $LOG            # when:  Thu Aug 10 07:48:13 UTC 2017
whoami | tee -a $LOG       # who:   root
pwd | tee -a $LOG          # where: /home/vagrant

CACHE=/vagrant/cache
[ -d $CACHE ] || mkdir -p $CACHE 

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

function download_neutron() {
    NEUTRON_PLUGIN_ML2_VERSION=2:10.0.3-0ubuntu1~cloud0
    NEUTRON_OPENVSWITCH_AGENT_VERSION=2:10.0.3-0ubuntu1~cloud0
    NEUTRON_L3_AGENT_VERSION=2:10.0.3-0ubuntu1~cloud0
    NEUTRON_DHCP_AGENT_VERSION=2:10.0.3-0ubuntu1~cloud0
    NEUTRON_METADATA_AGENT_VERSION=2:10.0.3-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt install -y neutron-plugin-ml2=$NEUTRON_PLUGIN_ML2_VERSION \
                   neutron-openvswitch-agent=$NEUTRON_OPENVSWITCH_AGENT_VERSION \
                   neutron-l3-agent=$NEUTRON_L3_AGENT_VERSION \
                   neutron-dhcp-agent=$NEUTRON_DHCP_AGENT_VERSION \
                   neutron-metadata-agent=$NEUTRON_METADATA_AGENT_VERSION
#    apt install -y neutron-plugin-ml2 \
#                   neutron-openvswitch-agent \
#                   neutron-l3-agent \
#                   neutron-dhcp-agent \
#                   neutron-metadata-agent
}

function configure_neutron() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Edit the /etc/sysctl.conf
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    sed -i "$ a net.ipv4.ip_forward = 1" /etc/sysctl.conf
    sed -i "$ a net.ipv4.conf.all.rp_filter = 0" /etc/sysctl.conf
    sed -i "$ a net.ipv4.conf.default.rp_filter = 0" /etc/sysctl.conf
    sysctl -p

    # Edit the /etc/neutron/neutron.conf file, [database] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    sed -i "s|^connection = |#connection = |" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a service_plugins = router" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a allow_overlapping_ips = True" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a transport_url = rabbit://openstack:RABBIT_PASS@os-controller" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a auth_strategy = keystone" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [keystone_authtoken] section
    echo -e "auth_uri = http://os-controller:5000\nauth_url = http://os-controller:35357\nmemcached_servers = os-controller:11211\nauth_type = password\nproject_domain_name = Default\nuser_domain_name = Default\nproject_name = service\nusername = neutron\npassword = NEUTRON_PASS\n" | sed -i "/^\[keystone_authtoken\]/ r /dev/stdin" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file, [ml2] section
    sed -i "/^\[ml2\]$/ a type_drivers = flat,vlan,vxlan" /etc/neutron/plugins/ml2/ml2_conf.ini
    sed -i "/^\[ml2\]$/ a tenant_network_types = vxlan" /etc/neutron/plugins/ml2/ml2_conf.ini
    sed -i "/^\[ml2\]$/ a mechanism_drivers = openvswitch,l2population" /etc/neutron/plugins/ml2/ml2_conf.ini
    sed -i "/^\[ml2\]$/ a extension_drivers = port_security" /etc/neutron/plugins/ml2/ml2_conf.ini

    # Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file, [ml2_type_flat] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    sed -i "/^\[ml2_type_flat\]$/ a flat_networks = external" /etc/neutron/plugins/ml2/ml2_conf.ini

    # Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file, [ml2_type_vxlan] section
    sed -i "/^\[ml2_type_vxlan\]$/ a vni_ranges = 1:1000" /etc/neutron/plugins/ml2/ml2_conf.ini

    # Edit the /etc/neutron/plugins/ml2/ml2_conf.ini file, [securitygroup] section
    sed -i "/^\[securitygroup\]$/ a enable_ipset = True" /etc/neutron/plugins/ml2/ml2_conf.ini

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [ovs] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    sed -i "/^\[ovs\]$/ a local_ip = $ENV_TUNNEL_OS_NETWORK_IP" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[ovs\]$/ a bridge_mappings = external:br-ex" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [agent] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    sed -i "/^\[agent\]$/ a tunnel_types = vxlan" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[agent\]$/ a l2_population = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[agent\]$/ a prevent_arp_spoofing = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [securitygroup] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    sed -i "/^\[securitygroup\]$/ a enable_security_group = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[securitygroup\]$/ a firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Edit the /etc/neutron/l3_agent.ini file, [DEFAULT] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    sed -i "/^\[DEFAULT\]$/ a interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver" /etc/neutron/l3_agent.ini

    # Edit the /etc/neutron/dhcp_agent.ini file, [DEFAULT] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    sed -i "/^\[DEFAULT\]$/ a interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver" /etc/neutron/dhcp_agent.ini
    sed -i "/^\[DEFAULT\]$/ a dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq" /etc/neutron/dhcp_agent.ini
    sed -i "/^\[DEFAULT\]$/ a enable_isolated_metadata = True" /etc/neutron/dhcp_agent.ini
    sed -i "/^\[DEFAULT\]$/ a dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf" /etc/neutron/dhcp_agent.ini

    # Create the /etc/neutron/dnsmasq-neutron.conf file to adjust MTU
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    echo "dhcp-option-force=26,1450" > /etc/neutron/dnsmasq-neutron.conf
    chgrp neutron /etc/neutron/dnsmasq-neutron.conf

    # Edit the /etc/neutron/metadata_agent.ini file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a nova_metadata_ip = os-controller" /etc/neutron/metadata_agent.ini
    sed -i "/^\[DEFAULT\]$/ a metadata_proxy_shared_secret = METADATA_SECRET" /etc/neutron/metadata_agent.ini

    # Configure OVS
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    ifconfig $ENV_PUBLIC_INTERFACE 0.0.0.0
    service openvswitch-switch restart
    ovs-vsctl add-br br-ex
    ovs-vsctl add-port br-ex $ENV_PUBLIC_INTERFACE

    # Restart the Networking services
    service openvswitch-switch restart
    service neutron-openvswitch-agent restart
    service neutron-dhcp-agent restart
    service neutron-metadata-agent restart
    service neutron-l3-agent restart

    # Log files
    # /var/log/neutron/neutron-dhcp-agent.log
    # /var/log/neutron/neutron-l3-agent.log
    # /var/log/neutron/neutron-metadata-agent.log
    # /var/log/neutron/neutron-openvswitch-agent.log
    # /var/log/neutron/neutron-ovs-cleanup.log
    # /var/log/openvswitch/ovsdb-server.log
    # /var/log/openvswitch/ovs-vswitchd.log

    # References
    # https://docs.openstack.org/newton/install-guide-ubuntu/neutron-controller-install.html
    # https://docs.openstack.org/newton/install-guide-ubuntu/neutron-controller-install-option2.html
    # https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#network-node
    # https://www.centos.bz/2012/04/linux-sysctl-conf/
}

function download_lbaas() {
    NEUTRON_LBAAS_AGENT_VERSION=2:10.0.1-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt install -y neutron-lbaasv2-agent=$NEUTRON_LBAAS_AGENT_VERSION
    #apt install -y python-neutron-lbaas=

    # Reference https://docs.openstack.org/ocata/networking-guide/config-lbaas.html
}

function configure_lbaas() {
    # Edit the /etc/neutron/lbaas_agent.ini file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a interface_driver = openvswitch" /etc/neutron/lbaas_agent.ini
    sed -i "/^\[DEFAULT\]$/ a ovs_use_veth = False" /etc/neutron/lbaas_agent.ini

    # Edit the /etc/neutron/lbaas_agent.ini file, [haproxy] section
    cat >> /etc/neutron/lbaas_agent.ini <<DATA
[haproxy]
user_group = haproxy
DATA

    # Edit the /etc/neutron/neutron_lbaas.conf file, [service_providers] section
    sed -i "/^\[service_providers\]$/ a service_provider = LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default" /etc/neutron/neutron_lbaas.conf

    # Restart the Networking services
    service neutron-lbaasv2-agent restart

    # Reference https://docs.openstack.org/ocata/networking-guide/config-lbaas.html
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
                download_neutron
                download_lbaas
                ;;
            configure)
                configure_neutron
                configure_lbaas
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
