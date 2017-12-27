set -e

#------------------------------

tar -zxf etc.tgz etc/neutron

#------------------------------

sed -i '/^#/ d' etc/neutron/neutron.conf
sed -i '/^$/ d' etc/neutron/neutron.conf

sed -i '/^#/ d' etc/neutron/plugins/ml2/ml2_conf.ini
sed -i '/^$/ d' etc/neutron/plugins/ml2/ml2_conf.ini

sed -i '/^#/ d' etc/neutron/plugins/ml2/openvswitch_agent.ini
sed -i '/^$/ d' etc/neutron/plugins/ml2/openvswitch_agent.ini

#------------------------------
