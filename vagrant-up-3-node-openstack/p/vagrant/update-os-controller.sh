#!/bin/bash

set -e

ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"
ENV_MGMT_OS_OBJECT_IP="10.0.0.61"

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
    #apt-get install -y swift swift-proxy python-swiftclient python-keystoneclient python-keystonemiddleware
    apt-get install -y swift swift-proxy python-swiftclient
}

function configure_swift() {
    # [ PART I ]

     # Create the user
    source /root/admin-openrc
    openstack user create --domain default --password SWIFT_PASS swift

    # Associate the user with the admin role and the service project
    source /root/admin-openrc
    openstack role add --project service --user swift admin

    # Create the service entity
    source /root/admin-openrc
    openstack service create --name swift --description "OpenStack Object Storage" object-store

    # Create the service api endpoint
    source /root/admin-openrc
    openstack endpoint create --region RegionOne object-store public http://os-controller:8080/v1/AUTH_%\(project_id\)s
    openstack endpoint create --region RegionOne object-store internal http://os-controller:8080/v1/AUTH_%\(project_id\)s
    openstack endpoint create --region RegionOne object-store admin http://os-controller:8080/v1

    # Create the /etc/swift directory
    [ -d /etc/swift ] || mkdir /etc/swift

    # Create /etc/swift/proxy-server.conf
    cp plus-swift/sample.conf/proxy-server.conf /etc/swift/proxy-server.conf

    # Edit the /etc/swift/proxy-server.conf file, [DEFAULT] section
    crudini --set /etc/swift/proxy-server.conf DEFAULT bind_port "8080"
    crudini --set /etc/swift/proxy-server.conf DEFAULT user "swift"
    crudini --set /etc/swift/proxy-server.conf DEFAULT swift_dir "/etc/swift"

    # Edit the /etc/swift/proxy-server.conf file, [pipeline:main] section
    crudini --set /etc/swift/proxy-server.conf pipeline:main pipeline "catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server"

    # Edit the /etc/swift/proxy-server.conf file, [app:proxy-server] section
    crudini --set /etc/swift/proxy-server.conf app:proxy-server use "egg:swift#proxy"
    crudini --set /etc/swift/proxy-server.conf app:proxy-server account_autocreate "True"

    # Edit the /etc/swift/proxy-server.conf file, [filter:keystoneauth] section
    crudini --set /etc/swift/proxy-server.conf filter:keystoneauth use "egg:swift#keystoneauth"
    crudini --set /etc/swift/proxy-server.conf filter:keystoneauth operator_roles "admin,user"

    # Edit the /etc/swift/proxy-server.conf file, [filter:authtoken] section
    crudini --set /etc/swift/proxy-server.conf filter:authtoken paste.filter_factory "keystonemiddleware.auth_token:filter_factory"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_uri "http://os-controller:5000"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_url "http://os-controller:35357"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken memcached_servers "os-controller:11211"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_type "password"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken project_domain_id "default"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken user_domain_id "default"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken project_name "service"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken username "swift"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken password "SWIFT_PASS"
    crudini --set /etc/swift/proxy-server.conf filter:authtoken delay_auth_decision "True"

    # Edit the /etc/swift/proxy-server.conf file, [filter:cache] section
    crudini --set /etc/swift/proxy-server.conf filter:cache use "egg:swift#memcache"
    crudini --set /etc/swift/proxy-server.conf filter:cache memcache_servers "os-controller:11211"

    # [ PART II ] - Create and distribute initial rings

    # Change to the /etc/swift directory
    cd /etc/swift

    # Create account ring :: Create the base account.builder file
    swift-ring-builder account.builder create 10 1 1

    # Create account ring :: Add each storage node to the ring
    swift-ring-builder account.builder add --region 1 --zone 1 --ip $ENV_MGMT_OS_OBJECT_IP --port 6202 --device sdb --weight 100
    swift-ring-builder account.builder add --region 1 --zone 1 --ip $ENV_MGMT_OS_OBJECT_IP --port 6202 --device sdc --weight 100

    # Create account ring :: Verify the ring contents
    swift-ring-builder account.builder

    # Create account ring :: Rebalance the ring
    swift-ring-builder account.builder rebalance

    # Create container ring :: Create the base container.builder file
    swift-ring-builder container.builder create 10 1 1

    # Create container ring :: Add each storage node to the ring
    swift-ring-builder container.builder add --region 1 --zone 1 --ip $ENV_MGMT_OS_OBJECT_IP --port 6201 --device sdb --weight 100
    swift-ring-builder container.builder add --region 1 --zone 1 --ip $ENV_MGMT_OS_OBJECT_IP --port 6201 --device sdc --weight 100

    # Create container ring :: Verify the ring contents
    swift-ring-builder container.builder

    # Create container ring :: Rebalance the ring
    swift-ring-builder container.builder rebalance


    # Create object ring :: Create the base object.builder file
    swift-ring-builder object.builder create 10 1 1

    # Create object ring :: Add each storage node to the ring
    swift-ring-builder object.builder add --region 1 --zone 1 --ip $ENV_MGMT_OS_OBJECT_IP --port 6200 --device sdb --weight 100
    swift-ring-builder object.builder add --region 1 --zone 1 --ip $ENV_MGMT_OS_OBJECT_IP --port 6200 --device sdc --weight 100

    # Create object ring :: Verify the ring contents
    swift-ring-builder object.builder

    # Create object ring :: Rebalance the ring
    swift-ring-builder object.builder rebalance

    # Copy the account.ring.gz, container.ring.gz, and object.ring.gz files to the /etc/swift directory on each storage node and any additional nodes running the proxy service TODO

    # Change back to previous directory
    cd -
    
    # [ PART III ] - Finalize installation

    # Create the /etc/swift/swift.conf file
    cp plus-swift/sample.conf/swift.conf /etc/swift/swift.conf

    # Edit the /etc/swift/swift.conf file, [swift-hash] section
    crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix "HASH_PATH_SUFFIX"
    crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix "HASH_PATH_PREFIX"

    # Edit the /etc/swift/swift.conf file, [storage-policy:0] section
    crudini --set /etc/swift/swift.conf storage-policy:0 name "Policy-0"
    crudini --set /etc/swift/swift.conf storage-policy:0 default "yes"

    # Copy the swift.conf file to the /etc/swift directory on each storage node and any additional nodes running the proxy service TODO

    # On all nodes, ensure proper ownership of the configuration directory TODO

    # Restart the Object Storage proxy service including its dependencies
    service memcached restart
    service swift-proxy restart

    # On the storage nodes, start the Object Storage services TODO
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
