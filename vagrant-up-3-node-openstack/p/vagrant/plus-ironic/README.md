# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-ironic"
```

Update os-compute

```
vagrant ssh os-compute -c "sudo /vagrant/update-os-compute.sh plus-ironic"
```

Prepare a virtualbox machine for baremetal node

```
?
```

Verify bare metal service

```
ironic driver-list
```

# REF

REF https://www.ibm.com/developerworks/cn/cloud/library/cl-cn-virtualboxironic/index.html

REF https://docs.openstack.org/ironic/latest/

REF https://kairen.github.io/2017/08/16/openstack/ironic-dev/

REF https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux_openstack_platform/7/html/bare_metal_provisioning/install_and_configure_openstack_bare_metal_provisioning_ironic

REF https://docs.openstack.org/ironic/mitaka/drivers/vbox.html

REF https://dtantsur.github.io/talks/pike-ironic-deploy-deep-dive/#/

REF https://docs.openstack.org/ironic/latest/install/enabling-drivers.html

```
# Start the VirtualBox web service with null authentication
VBoxManage setproperty websrvauthlibrary null
vboxwebsrv --host 0.0.0.0
```

```
pip install pyremotevbox==0.5.0
pip install ZSI
```

```
# http://www.echojb.com/network/2017/05/06/375676.html
import pyremotevbox.vbox as vbox
host = vbox.VirtualBoxHost(host='10.0.2.2')
bm1 = host.find_vm('minikube')
bm1.get_power_status()

# 'PoweredOff'
```
