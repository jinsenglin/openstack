# Snapshot restore

SOP:
* delete instance
* boot instance from snapshot image

---

# Delete instance

Example

```
# delete instance
openstack server delete --wait $H

# boot instance from snapshot image
openstack create --image $I --flavor $F --key-name $K --nic port-id=$P --wait $H

# get api token
API_TOKEN=$(openstack token issue -c id -f value)

# get api endpoint
API_ENDPOINT=http://$CONTROLLER:8774/v2.1

# get server id by server name
HID=$(openstack server show $H -c id -f value)

# attach security group to server
curl -X POST $API_ENDPOINT/servers/$HID/action -H "Content-Type: application/json" -H "X-Auth-Token: $API_TOKEN" -d "{\"addSecurityGroup\": {\"name\": \"open-all\"}}"

# attach floating ip
openstack server add floating ip $H $FIP
```

---

# Boot instance from snapshot image

Example

```
openstack server create ?
```
