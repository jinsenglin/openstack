REF https://www.ibm.com/developerworks/cn/cloud/library/cl-cn-virtualboxironic/index.html

REF https://docs.openstack.org/ironic/latest/

REF https://kairen.github.io/2017/08/16/openstack/ironic-dev/

REF https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux_openstack_platform/7/html/bare_metal_provisioning/install_and_configure_openstack_bare_metal_provisioning_ironic

REF https://docs.openstack.org/ironic/mitaka/drivers/vbox.html

REF https://dtantsur.github.io/talks/pike-ironic-deploy-deep-dive/#/

```
vboxwebsrv --host 0.0.0.0
```

```
# https://pypi.python.org/pypi/pyremotevbox/
pip install pyremotevbox==0.5.0
```

```
import pyremotevbox
host = pyremotevbox.VirtualBoxHost('10.0.2.2')
bm1 = host.find_vm('minikube')
bm1.get_power_status()

# 'PoweredOff'
```
