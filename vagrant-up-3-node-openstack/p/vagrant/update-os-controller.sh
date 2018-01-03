#!/bin/bash

set -e

ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"
ENV_MGMT_OS_OBJECT_IP="10.0.0.61"

CACHE=/vagrant/cache
[ -d $CACHE ] || mkdir -p $CACHE 

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

function configure_swift_part1() {
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
    cp /vagrant/plus-swift/sample.conf/proxy-server.conf /etc/swift/proxy-server.conf

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
}

function configure_swift_part2() {
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

    # Copy the account.ring.gz, container.ring.gz, and object.ring.gz files to the /etc/swift directory on each storage node and any additional nodes running the proxy service
    [ -d /vagrant/plus-swift/cache ] || mkdir /vagrant/plus-swift/cache
    cp account.ring.gz /vagrant/plus-swift/cache/
    cp container.ring.gz /vagrant/plus-swift/cache/
    cp object.ring.gz /vagrant/plus-swift/cache/

    # Change back to previous directory
    cd -
}
    
function configure_swift_part3() {
    # [ PART III ] - Finalize installation

    # Create the /etc/swift/swift.conf file
    cp /vagrant/plus-swift/sample.conf/swift.conf /etc/swift/swift.conf

    # Edit the /etc/swift/swift.conf file, [swift-hash] section
    crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix "HASH_PATH_SUFFIX"
    crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix "HASH_PATH_PREFIX"

    # Edit the /etc/swift/swift.conf file, [storage-policy:0] section
    crudini --set /etc/swift/swift.conf storage-policy:0 name "Policy-0"
    crudini --set /etc/swift/swift.conf storage-policy:0 default "yes"

    # Copy the swift.conf file to the /etc/swift directory on each storage node and any additional nodes running the proxy service
    [ -d /vagrant/plus-swift/cache ] || mkdir /vagrant/plus-swift/cache
    cp /etc/swift/swift.conf /vagrant/plus-swift/cache/

    # On all nodes, ensure proper ownership of the configuration directory
    chown -R root:swift /etc/swift

    # Restart the Object Storage proxy service including its dependencies
    service memcached restart
    service swift-proxy restart
}

function download_barbican() {
    apt-get install -y barbican-api barbican-keystone-listener barbican-worker
}

function configure_barbican() {
    # Create the database
    mysql <<DATA
CREATE DATABASE barbican;
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY 'BARBICAN_DBPASS';
GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY 'BARBICAN_DBPASS';
DATA

    # Create the user
    source /root/admin-openrc
    openstack user create --domain default --password BARBICAN_PASS barbican

    # Associate the user with the admin role and the service project
    source /root/admin-openrc
    openstack role add --project service --user barbican admin

    # Create new role 'creator'
    source /root/admin-openrc
    openstack role create creator

    # Associate the user with the creator role and the service project
    openstack role add --project service --user barbican creator

    # Create the service entity
    openstack service create --name barbican --description "Key Manager" key-manager

    # Create the service api endpoint
    openstack endpoint create --region RegionOne key-manager public http://os-controller:9311
    openstack endpoint create --region RegionOne key-manager internal http://os-controller:9311
    openstack endpoint create --region RegionOne key-manager admin http://os-controller:9311

    # Edit the /etc/barbican/barbican.conf file, [DEFAULT] section
    crudini --set /etc/barbican/barbican.conf DEFAULT sql_connection "mysql+pymysql://barbican:BARBICAN_DBPASS@os-controller/barbican"
    crudini --set /etc/barbican/barbican.conf DEFAULT transport_url "rabbit://openstack:RABBIT_PASS@os-controller"

    # Edit the /etc/barbican/barbican.conf file, [keystone_authtoken] section
    crudini --set /etc/barbican/barbican.conf keystone_authtoken auth_uri "http://os-controller:5000"
    crudini --set /etc/barbican/barbican.conf keystone_authtoken auth_url "http://os-controller:35357"
    crudini --set /etc/barbican/barbican.conf keystone_authtoken memcached_servers "os-controller:11211"
    crudini --set /etc/barbican/barbican.conf keystone_authtoken auth_type "password"
    crudini --set /etc/barbican/barbican.conf keystone_authtoken project_domain_name "default"
    crudini --set /etc/barbican/barbican.conf keystone_authtoken user_domain_name "default"
    crudini --set /etc/barbican/barbican.conf keystone_authtoken project_name "service"
    crudini --set /etc/barbican/barbican.conf keystone_authtoken username "barbican"
    crudini --set /etc/barbican/barbican.conf keystone_authtoken password "BARBICAN_PASS"

    # Populate the database
    su -s /bin/sh -c "barbican-manage db upgrade" barbican

    # Restart the Key Manager services
    # service openstack-barbican-api restart # deprecated
    service apache2 restart
}

function download_heat() {
    apt-get install -y heat-api heat-api-cfn heat-engine
}

function configure_heat() {
    # Create the database
    mysql <<DATA
CREATE DATABASE heat;
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY 'HEAT_DBPASS';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY 'HEAT_DBPASS';
DATA

    # Create the user
    source /root/admin-openrc
    openstack user create --domain default --password HEAT_PASS heat

    # Associate the user with the admin role and the service project
    source /root/admin-openrc
    openstack role add --project service --user heat admin

    # Create the service entity
    openstack service create --name heat --description "Orchestration" orchestration
    openstack service create --name heat-cfn --description "Orchestration"  cloudformation

    # Create the service api endpoint
    openstack endpoint create --region RegionOne orchestration public http://os-controller:8004/v1/%\(tenant_id\)s
    openstack endpoint create --region RegionOne orchestration internal http://os-controller:8004/v1/%\(tenant_id\)s
    openstack endpoint create --region RegionOne orchestration admin http://os-controller:8004/v1/%\(tenant_id\)s
    openstack endpoint create --region RegionOne cloudformation public http://os-controller:8000/v1
    openstack endpoint create --region RegionOne cloudformation internal http://os-controller:8000/v1
    openstack endpoint create --region RegionOne cloudformation admin http://os-controller:8000/v1

    # NOTE Orchestration requires additional information in the Identity service to manage stacks.

    # Create the heat domain
    openstack domain create --description "Stack projects and users" heat

    # Create the heat_domain_admin user to manage projects and users in the heat domain
    openstack user create --domain heat --password HEAT_DOMAIN_PASS heat_domain_admin

    # Add the admin role to the heat_domain_admin user in the heat domain to enable administrative stack management privileges by the heat_domain_admin user
    openstack role add --domain heat --user-domain heat --user heat_domain_admin admin

    # Create the heat_stack_owner role
    openstack role create heat_stack_owner

    # Add the heat_stack_owner role to the demo project and user to enable stack management by the demo user
    openstack role add --project demo --user demo heat_stack_owner

    # NOTE You must add the heat_stack_owner role to each user that manages stacks.

    # Create the heat_stack_user role
    openstack role create heat_stack_user

    # NOTE The Orchestration service automatically assigns the heat_stack_user role to users that it creates during stack deployment. By default, this role restricts API <Application Programming Interface (API)> operations. To avoid conflicts, do not add this role to users with the heat_stack_owner role.

    # Edit the /etc/heat/heat.conf file, [database] section
    crudini --set /etc/heat/heat.conf database connection "mysql+pymysql://heat:HEAT_DBPASS@os-controller/heat"

    # Edit the /etc/heat/heat.conf file, [DEFAULT] section
    crudini --set /etc/heat/heat.conf DEFAULT transport_url "rabbit://openstack:RABBIT_PASS@os-controller"
    crudini --set /etc/heat/heat.conf DEFAULT heat_metadata_server_url "http://os-controller:8000"
    crudini --set /etc/heat/heat.conf DEFAULT heat_waitcondition_server_url "http://os-controller:8000/v1/waitcondition"
    crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin "heat_domain_admin"
    crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin_password "HEAT_DOMAIN_PASS"
    crudini --set /etc/heat/heat.conf DEFAULT stack_user_domain_name "heat"

    # Edit the /etc/heat/heat.conf file, [keystone_authtoken] section
    crudini --set /etc/heat/heat.conf keystone_authtoken auth_uri "http://os-controller:5000"
    crudini --set /etc/heat/heat.conf keystone_authtoken auth_url "http://os-controller:35357"
    crudini --set /etc/heat/heat.conf keystone_authtoken memcached_servers "os-controller:11211"
    crudini --set /etc/heat/heat.conf keystone_authtoken auth_type "password"
    crudini --set /etc/heat/heat.conf keystone_authtoken project_domain_name "default"
    crudini --set /etc/heat/heat.conf keystone_authtoken user_domain_name "default"
    crudini --set /etc/heat/heat.conf keystone_authtoken project_name "service"
    crudini --set /etc/heat/heat.conf keystone_authtoken username "heat"
    crudini --set /etc/heat/heat.conf keystone_authtoken password "HEAT_PASS"

    # Edit the /etc/heat/heat.conf file, [trustee] section
    crudini --set /etc/heat/heat.conf trustee auth_type "password"
    crudini --set /etc/heat/heat.conf trustee auth_url "http://os-controller:35357"
    crudini --set /etc/heat/heat.conf trustee username "heat"
    crudini --set /etc/heat/heat.conf trustee password "HEAT_PASS"
    crudini --set /etc/heat/heat.conf trustee user_domain_name "default"

    # Edit the /etc/heat/heat.conf file, [clients_keystone] section
    crudini --set /etc/heat/heat.conf clients_keystone auth_uri "http://os-controller:35357"

    # Edit the /etc/heat/heat.conf file, [ec2authtoken] section
    crudini --set /etc/heat/heat.conf ec2authtoken auth_uri "http://os-controller:5000/v3"

    # Populate the database
    su -s /bin/sh -c "heat-manage db_sync" heat

    # Restart the Orchestration services
    service heat-api restart
    service heat-api-cfn restart
    service heat-engine restart
}

function download_ironic() {
    apt-get install -y python-ironicclient
}

function configure_ironic() {
    # Create the database
    mysql <<DATA
CREATE DATABASE ironic CHARACTER SET utf8;
GRANT ALL PRIVILEGES ON ironic.* TO 'ironic'@'localhost' IDENTIFIED BY 'IRONIC_DBPASSWORD';
GRANT ALL PRIVILEGES ON ironic.* TO 'ironic'@'%' IDENTIFIED BY 'IRONIC_DBPASSWORD';
DATA
    # configure_ironic_identity
    # configure_ironic_compute
    # configure_ironic_networking
    # configure_ironic_image
    # configure_ironic_cleaning
    # configure_ironic_tenant_networks
    # configure_ironic_new_image
    # configure_ironic_new_flavor
}

function configure_ironic_identity() {
    :
}

function configure_ironic_compute() {
    :
}

function configure_ironic_networking() {
    :
}

function configure_ironic_image() {
    :
}

function configure_ironic_cleaning() {
    :
}

function configure_ironic_tenant_networks() {
    :
}

function configure_ironic_new_image() {
    :
}

function configure_ironic_new_flavor() {
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
            configure-swift-part1)
                configure_swift_part1
                ;;
            configure-swift-part3)
                configure_swift_part2
                ;;
            configure-swift-part5)
                configure_swift_part3
                ;;
            download-barbican)
                download_barbican
                ;;
            configure-barbican)
                configure_barbican
                ;;
            plus-barbican)
                download_barbican
                configure_barbican
                ;;
            download-heat)
                download_heat
                ;;
            configure-heat)
                configure_heat
                ;;
            plus-heat)
                download_heat
                configure_heat
                ;;
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
