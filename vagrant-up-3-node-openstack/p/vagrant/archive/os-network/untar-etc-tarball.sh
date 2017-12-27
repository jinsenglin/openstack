set -e

#------------------------------

tar -zxf etc.tgz etc/neutron

#------------------------------

sed -i '/^#/ d' etc/neutron/neutron.conf
sed -i '/^$/ d' etc/neutron/neutron.conf

#------------------------------
