set -e

#------------------------------

tar -zxf etc.tgz etc/neutron
tar -zxf etc.tgz etc/nova

#------------------------------

sed -i '/^#/ d' etc/neutron/neutron.conf
sed -i '/^$/ d' etc/neutron/neutron.conf

sed -i '/^#/ d' etc/nova/nova.conf
sed -i '/^$/ d' etc/nova/nova.conf

#------------------------------
