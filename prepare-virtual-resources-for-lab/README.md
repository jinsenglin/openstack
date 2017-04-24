# Parepare Virtual Resources for Lab

Resources

* 5 machines
* 6 private ips
* 1 floating ip
* 1 image
* 1 key pair
* 1 security group
* 1 flavor

---

flavor name: $F

---

security group name: $SG

---

key pair name: $KP

---

image name: $I

---

floating ip: $FIP

---

private ips:
* 192.168.100.190 (name: PIP1)
* 192.168.100.191 (name: PIP2)
* 192.168.100.192 (name: PIP3)
* 192.168.100.193 (name: PIP4)
* 192.168.100.194 (name: PIP5)
* 192.168.100.195 (name: PIP6)

private network name: $PN
private subnet name: $PSN

```bash
openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=192.168.100.190 port1
```
---
