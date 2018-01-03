#!/bin/bash

ENV_MGMT_OS_COMPUTE_IP="10.0.0.31"

function download_ironic() {
    apt-get install -y ironic-api ironic-conductor
}

function configure_ironic() {
    :
    # configure_ironic_api
    # configure_ironic_conductor
}

function configure_ironic_api() {
    # Edit the /etc/ironic/ironic.conf file, [database] section
    crudini --set /etc/ironic/ironic.conf database connection "mysql+pymysql://ironic:IRONIC_DBPASSWORD@os-controller/ironic?charset=utf8"

    # Edit the /etc/ironic/ironic.conf file, [DEFAULT] section
    crudini --set /etc/ironic/ironic.conf DEFAULT transport_url "rabbit://openstack:RABBIT_PASS@os-controller"
    crudini --set /etc/ironic/ironic.conf DEFAULT auth_strategy "keystone"

    # Edit the /etc/ironic/ironic.conf file, [keystone_authtoken] section
    crudini --set /etc/ironic/ironic.conf keystone_authtoken auth_uri "http://os-controller:5000"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken auth_url "http://os-controller:35357"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken memcached_servers "os-controller:11211"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken auth_type "password"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken project_domain_name "default"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken user_domain_name "default"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken project_name "service"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken username "ironic"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken password "IRONIC_PASSWORD"

    # Populate the database
    ironic-dbsync --config-file /etc/ironic/ironic.conf create_schema

    # Restart the ironic-api service
    service ironic-api restart
}

function configure_ironic_conductor() {
    # Edit the /etc/ironic/ironic.conf file, [database] section
    crudini --set /etc/ironic/ironic.conf database connection "mysql+pymysql://ironic:IRONIC_DBPASSWORD@os-controller/ironic?charset=utf8"

    # Edit the /etc/ironic/ironic.conf file, [DEFAULT] section
    crudini --set /etc/ironic/ironic.conf DEFAULT my_ip "$ENV_MGMT_OS_COMPUTE_IP"
    crudini --set /etc/ironic/ironic.conf DEFAULT transport_url "rabbit://openstack:RABBIT_PASS@os-controller"
    crudini --set /etc/ironic/ironic.conf DEFAULT auth_strategy "keystone"

    # Edit the /etc/ironic/ironic.conf file, [keystone_authtoken] section
    crudini --set /etc/ironic/ironic.conf keystone_authtoken auth_uri "http://os-controller:5000"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken auth_url "http://os-controller:35357"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken memcached_servers "os-controller:11211"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken auth_type "password"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken project_domain_name "default"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken user_domain_name "default"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken project_name "service"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken username "ironic"
    crudini --set /etc/ironic/ironic.conf keystone_authtoken password "IRONIC_PASSWORD"

    # Configure enabled drivers and hardware types TODO
    crudini --set /etc/ironic/ironic.conf DEFAULT enabled_drivers "pxe_vbox"
    crudini --set /etc/ironic/ironic.conf DEFAULT enabled_hardware_types "ipmi"
    crudini --set /etc/ironic/ironic.conf DEFAULT enabled_boot_interfaces "pxe"
    crudini --set /etc/ironic/ironic.conf DEFAULT enabled_deploy_interfaces "iscsi"
    crudini --set /etc/ironic/ironic.conf DEFAULT enabled_network_interfaces "flat,neutron"
    crudini --set /etc/ironic/ironic.conf DEFAULT default_deploy_interface "iscsi"
    crudini --set /etc/ironic/ironic.conf DEFAULT default_network_interface "neutron"

    # Restart the ironic-conductor service
    service ironic-conductor restart
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download-ironic)
                download_ironic
                ;;
            configure-ironic)
                configure_ironic
                ;;
            plus-ironic)
                download_ironic
                configure_ironic
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
