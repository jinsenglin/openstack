#!/bin/bash

set -e

function download_neutron_lbaasv2_haproxy() {
    apt-get install -y neutron-lbaasv2-agent
}

function configure_neutron_lbaasv2_haproxy() {
    # Edit the /etc/neutron/lbaas_agent.ini file, [DEFAULT] section
    crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver openvswitch
    
    # Edit the /etc/neutron/neutron_lbaas.conf file, [service_providers] section
    crudini --set /etc/neutron/neutron_lbaas.conf service_providers service_provider LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
    
    # Start the LBaaS v2 agent
    service neutron-lbaasv2-agent start
}

function download_neutron_fwaasv2() {
    :
}

function configure_neutron_fwaasv2() {
#    # Edit the /etc/neutron/neutron.conf file, [DEFAULT] section
#    crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins $(crudini --get /etc/neutron/neutron.conf DEFAULT service_plugins),firewall_v2
    
    # Edit the /etc/neutron/fwaas_driver.ini file, [fwaas] section
    crudini --set /etc/neutron/fwaas_driver.ini fwaas agent_version v2
    crudini --set /etc/neutron/fwaas_driver.ini fwaas driver neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas_v2.IptablesFwaasDriver
    crudini --set /etc/neutron/fwaas_driver.ini fwaas enabled True

    # Edit the /etc/neutron/l3_agent.ini file, [AGENT] section
    crudini --set /etc/neutron/l3_agent.ini AGENT extensions = fwaas
 
    # Restart the neutron-l3-agent service
    service neutron-l3-agent restart
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download-neutron-lbaasv2-haproxy)
                download_neutron_lbaasv2_haproxy
                ;;
            configure-neutron-lbaasv2-haproxy)
                configure_neutron_lbaasv2_haproxy
                ;;
            plus-neutron-lbaasv2-haproxy)
                download_neutron_lbaasv2_haproxy
                configure_neutron_lbaasv2_haproxy
                ;;
            download-neutron-fwaasv2)
                download_neutron_fwaasv2
                ;;
            configure-neutron-fwaasv2)
                configure_neutron_fwaasv2
                ;;
            plus-neutron-fwaasv2)
                download_neutron_fwaasv2
                configure_neutron_fwaasv2
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
