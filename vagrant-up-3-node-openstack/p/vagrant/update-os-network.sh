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
            *)
                echo "unknown mode"
                ;;
        esac
        shift
    done
    echo done
}
main $@
