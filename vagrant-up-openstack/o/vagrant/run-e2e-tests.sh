#!/bin/bash

set -e

# Workaround
docker restart kubernetes-controller-manager
docker restart kubernetes-scheduler

# --------------------------------------------------------------------------------------------

source /root/demo-openrc
source /vagrant/cache/env.rc

# Create openstack server 'testvm'
nova boot --flavor m1.nano --image cirros --nic net-id=$DEMO_NET_ID --config-drive=true testvm
OS_VM1_IP=$(openstack server show testvm -f value -c addresses | awk -F '=' '{print $2}')

# Create k8s deployment 'demo'
kubectl run demo --image=demo:demo
K8S_POD1_NAME=$(kubectl get pods -l run=demo -o jsonpath='{.items[].metadata.name}')
kubectl get po $K8S_POD1_NAME

# Create k8s service 'demo'
kubectl expose deployment demo --port=80 --target-port=8080
K8S_SVC1_IP=$(kubectl get services demo -o json | jq -r '.spec.clusterIP')

# Scale k8s deployment 'demo'
kubectl scale deployment demo --replicas=2

# Check ik8s endpoints of pods
K8S_POD1_IP=$(kubectl get endpoints demo -o json | jq -r '.subsets[].addresses[0].ip')
K8S_POD2_IP=$(kubectl get endpoints demo -o json | jq -r '.subsets[].addresses[1].ip')

# Check network traffic between openstack server, k8s service, and k8s pods
kubectl exec $K8S_POD1_NAME -- curl -s http://127.0.0.1:8080
kubectl exec $K8S_POD1_NAME -- curl -s http://$K8S_POD1_IP:8080
kubectl exec $K8S_POD1_NAME -- curl -s http://$K8S_POD2_IP:8080
kubectl exec $K8S_POD1_NAME -- curl -s http://$K8S_SVC1_IP
kubectl exec $K8S_POD1_NAME -- curl -s http://$K8S_SVC1_IP
kubectl exec $K8S_POD1_NAME -- ping -c 1 $OS_VM1_IP

# Enter interavtive mode
kubectl exec -it $K8S_POD1_NAME -- bash

<<COMMANDS
export PS1='POD # '
ssh cirros@$OS_VM1_IP          # password: cubswin:)

export PS1='VM # '
hostname
curl http://$K8S_POD1_IP:8080
curl http://$K8S_POD2_IP:8080
curl http://$K8S_SVC1_IP
curl http://$K8S_SVC1_IP
exit # logout vm

exit # logout pod
COMMANDS
