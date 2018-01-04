# Note

* multi-tenant feature: no
* network interface: flat
* deploy interface: iscsi
* boot interface: pxe
* management interface: ipmi

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

```
pip install diskimage-builder

disk-image-create ubuntu vm dhcp-all-interfaces grub2 -o my-image
glance image-create --name user_image --visibility public --disk-format qcow2 --container-format qcow2 <my-image.initrdbaremetal dhcp-all-interfaces grub2 -o user_image

disk-image-create ironic-agent fedora -o ironic-deploy
glance image-create --name deploy-vmlinuz --visibility public --disk-format aki --container-format aki < my-deploy-ramdisk.kernel
glance image-create --name deploy-initrd --visibility public --disk-format ari --container-format ari < my-deploy-ramdisk.initramfs

#

ironic node-create -d pxe_vbox -i virtualbox_host='192.168.33.1' -i virtualbox_vmname='baremetal'

ironic port-create -n $NODE_UUID -a $MAC_ADDRESS

ironic node-update $NODE_UUID add properties/cpus=$CPU properties/memory_mb=$RAM_MB properties/local_gb=$DISK_GB properties/cpu_arch=$ARCH

ironic node-update $NODE_UUID add driver_info/deploy_kernel=$DEPLOY_VMLINUZ_UUID driver_info/deploy_ramdisk=$DEPLOY_INITRD_UUID

ironic node-set-maintenance $NODE_UUID off

nova boot --config-drive true --flavor my_flavor --image bare_root_pass instance-1

# 部署镜像部署成功后，物理节点的磁盘被通过 iSCSI 协议暴露给 Ironic-Conductor, 随后 Ironic-Conductor 会向物理节点磁盘中写入用户镜像
```


REF https://docs.openstack.org/ironic/latest/

REF https://kairen.github.io/2017/08/16/openstack/ironic-dev/

REF https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux_openstack_platform/7/html/bare_metal_provisioning/install_and_configure_openstack_bare_metal_provisioning_ironic

REF https://dtantsur.github.io/talks/pike-ironic-deploy-deep-dive/#/

REF https://docs.openstack.org/ironic/latest/install/enabling-drivers.html

REF https://docs.openstack.org/ironic/mitaka/drivers/vbox.html

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
