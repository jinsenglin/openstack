#!/bin/bash

set -e

ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"

function download_cinder() {
    apt-get install -y cinder-api cinder-scheduler
}

function configure_cinder() {
    # Create the database
    mysql <<DATA
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'CINDER_DBPASS';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'CINDER_DBPASS';
DATA

     # Create the user
    source /root/admin-openrc
    openstack user create --domain default --password CINDER_PASS cinder

    # Associate the user with the admin role and the service project
    source /root/admin-openrc
    openstack role add --project service --user cinder admin

    # Create the service entity
    source /root/admin-openrc
    openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
    openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

    # Create the service api endpoint
    source /root/admin-openrc
    openstack endpoint create --region RegionOne volumev2 public http://os-controller:8776/v2/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev2 internal http://os-controller:8776/v2/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev2 admin http://os-controller:8776/v2/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev3 public http://os-controller:8776/v3/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev3 internal http://os-controller:8776/v3/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev3 admin http://os-controller:8776/v3/%\(project_id\)s

    # Edit the /etc/cinder/cinder.conf file, [database] section
    crudini --set /etc/cinder/cinder.conf database connection "mysql+pymysql://cinder:CINDER_DBPASS@os-controller/cinder"

    # Edit the /etc/cinder/cinder.conf file, [DEFAULT] section
    crudini --set /etc/cinder/cinder.conf DEFAULT transport_url "rabbit://openstack:RABBIT_PASS@os-controller"
    crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy "keystone"
    crudini --set /etc/cinder/cinder.conf DEFAULT my_ip "$ENV_MGMT_OS_CONTROLLER_IP"

    # Edit the /etc/cinder/cinder.conf file, [keystone_authtoken] section
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri "http://os-controller:5000"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url "http://os-controller:35357"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers "os-controller:11211"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type "password"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name "default"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name "default"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name "service"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken username "cinder"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken password "CINDER_PASS"

    # Edit the /etc/cinder/cinder.conf file, [oslo_concurrency] section
    crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path "/var/lib/cinder/tmp"

    # Populate the database
    su -s /bin/sh -c "cinder-manage db sync" cinder

    # =========================================================================================================== #

    # Edit the /etc/nova/nova.conf file, [cinder] section
    crudini --set /etc/nova/nova.conf cinder os_region_name "RegionOne"

    # Restart the Compute API service
    service nova-api restart

    # Restart the Block Storage services
    service cinder-scheduler restart
    service apache2 restart
}

function download_swift() {
    :
}

function configure_swift() {
    :
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download-cinder)
                download_cinder
                ;;
            configure-cinder)
                configure_cinder
                ;;
            plus-cinder)
                download_cinder
                configure_cinder
                ;;
            download-swift)
                download_swift
                ;;
            configure-swift)
                configure_swift
                ;;
            plus-swift)
                download_swift
                configure_swift
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
