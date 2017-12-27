set -e

#------------------------------

tar -zxf etc.tgz etc/apache2
tar -zxf etc.tgz etc/chrony
tar -zxf etc.tgz etc/memcached.conf
tar -zxf etc.tgz etc/mysql
tar -zxf etc.tgz etc/rabbitmq

#------------------------------

tar -zxf etc.tgz etc/glance
tar -zxf etc.tgz etc/keystone
tar -zxf etc.tgz etc/neutron
tar -zxf etc.tgz etc/nova

#------------------------------

sed -i '/^#/ d' etc/glance/glance-registry.conf
sed -i '/^$/ d' etc/glance/glance-registry.conf

sed -i '/^#/ d' etc/keystone/keystone.conf
sed -i '/^$/ d' etc/keystone/keystone.conf

sed -i '/^#/ d' etc/neutron/neutron.conf
sed -i '/^$/ d' etc/neutron/neutron.conf

sed -i '/^#/ d' etc/nova/nova.conf
sed -i '/^$/ d' etc/nova/nova.conf

#------------------------------
