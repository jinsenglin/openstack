# Parepare Virtual Resources for Lab

Resources

* 2 machines
* 3 floating ip
* 3 private ips (1 for vip)
* 1 image (ubuntu 16)
* 1 key pair
* 1 security group (open all)
* 1 flavor

---

flavor name: $F

F=1C1G

---

security group name: $SG

SG=open-all

---

key pair name: $KP

KP="cclin mac"

---

image name: $I

I=ubuntu_16.04_server_LTS

---

private ips: $PIP1 $PIP2 $PIP3
* 192.168.100.191 (for vip)
* 192.168.100.192
* 192.168.100.193

private network name: $PN
private subnet name: $PSN

```
PIP1=192.168.100.191
PIP2=192.168.100.192
PIP3=192.168.100.193

PN=jimlin
PSN=jimlin

openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP1 $PIP1
PIP1ID=fdfc28e4-eb0d-4900-b834-cbafa02ba3ef 

openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP2 --allowed-address ip-address=$PIP1 $PIP2
PIP2ID=85547aa9-c15a-4336-aea0-fac9360afc6a

openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP3 --allowed-address ip-address=$PIP1 $PIP3
PIP3ID=0eda3542-44c6-4caf-a2de-20b311a74b5a
```

---

floating ips: $FIP1 $FIP2 $FIP3

public network name: $EN

```
openstack floating ip create --port $PIP1ID --fixed-ip-address $PIP1 $EN
FIP1=192.168.210.33
FIP1ID=2ca346a5-ca69-468a-aefb-ac65db177565

openstack floating ip create --port $PIP2ID --fixed-ip-address $PIP2 $EN
FIP2=192.168.210.52
FIP2ID=1abcd680-bfb4-4136-beed-1258385ea325

openstack floating ip create --port $PIP3ID --fixed-ip-address $PIP3 $EN
FIP3=192.168.210.20
FIP3ID=5d736e91-f0fb-45fb-8ec8-f3ebcd84e678
```

---

machines: $M1 $M2

```
M1=h01
openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP2 --wait $M1
M1ID=840e0e77-90b5-442b-835c-7c7d624401da

M2=h02
openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP3 --wait $M2
M2ID=c5b2bebe-d574-412d-a76e-797078d685e8 
```

---

# TODO

add security group to machines

---

# Keepalived Configuration

`sudo apt update && sudo apt install -y keepalived`

machine $M1 /etc/keepalived/keepalived.conf

```
vrrp_instance VIP_1 {
    state MASTER
    interface ens3
    virtual_router_id 51
    priority 250
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass supersecretpassword
    }
    virtual_ipaddress {
        192.168.100.191
    }
}
```

NOTE: 192.168.100.191 === $PIP1

machine $M2 /etc/keepalived/keepalived.conf

```
vrrp_instance VIP_1 {
    state BACKUP
    interface ens3
    virtual_router_id 51
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass supersecretpassword
    }
    virtual_ipaddress {
        192.168.100.191
    }
}
```

NOTE: 192.168.100.191 === $PIP1

Commands:

* systemctl restart keepalived
* systemctl start keepalived
* systemctl stop keepalived
* ip a
* ping $FIP1

---

# Keepalived Configuration 2

`sudo apt update && sudo apt install -y keepalived`

machine $M1 /etc/keepalived/keepalived.conf

```
vrrp_script chk_haproxy {
    script "killall -0 haproxy" # check the haproxy process
    interval 2 # every 2 seconds
}

vrrp_instance VIP_1 {
    state MASTER
    interface ens3
    virtual_router_id 51
    priority 250
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass supersecretpassword
    }
    virtual_ipaddress {
        192.168.100.191
    }
    track_script {
        chk_haproxy
    }
}
```

NOTE: 192.168.100.191 === $PIP1

machine $M2 /etc/keepalived/keepalived.conf

```
vrrp_script chk_haproxy {
    script "killall -0 haproxy" # check the haproxy process
    interval 2 # every 2 seconds
}

vrrp_instance VIP_1 {
    state BACKUP
    interface ens3
    virtual_router_id 51
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass supersecretpassword
    }
    virtual_ipaddress {
        192.168.100.191
    }
    track_script {
        chk_haproxy
    }
}
```

NOTE: 192.168.100.191 === $PIP1

Commands:

* systemctl restart keepalived
* systemctl start keepalived
* systemctl stop keepalived
* ip a
* ping $FIP1

---

# HAProxy Configuration

`sudo apt update && sudo apt install -y haproxy`

Both machine $M1 and $M2, file /etc/default/haproxy

```
ENABLED=1
```

Both machine $M1 and $M2, file /etc/haproxy/haproxy.cfg

```
listen webfarm 0.0.0.0:80
    mode http
    stats enable
    stats uri /haproxy?stats
    balance roundrobin
    option httpclose
    option forwardfor
    server webserver01 192.168.100.192:8080 check
    server webserver02 192.168.100.193:8080 check
```

NOTE: 192.168.100.192 === $PIP2

NOTE: 192.168.100.193 === $PIP3

Commands:
* systemctl restart haproxy
* systemctl start haproxy
* systemctl stop haproxy
* curl http://$FIP1:8080

---
