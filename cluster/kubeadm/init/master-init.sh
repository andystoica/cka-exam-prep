#!/bin/bash
### Script for initalisin the cluste on the master node
### This script needs to be run manually on the master node after the machine is up
### It generates the correct join-command script for the worker nodes


### Setup a cluster using kubeadm on the master node
printf '[1/5] Testing kubeadm connectivity by pulling K8s installation images\n'
kubeadm config images pull


### Initialise cluster
printf '[2/5] Initialising cluster using '$MASTER_IP' as the advertised address\n'
MASTER_IP=$(hostname -I | awk '{print $2}')
sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=10.244.0.0/16


### Add credentials for current user to interact with Kubernetes
printf '[3/5] Adding credentials for current user\n'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


### Install cluster networking
printf '[4/5] Installing Kubernetes network\n'
kubectl apply -f flannel.yaml


### Generate worker-init.sh script
printf '[5/5] Generating the worker init script\n'
printf "#!/bin/bash\n" > worker-init.sh
printf "### DO NOT EDIT! This script is generated automatically by master-init.sh.\n" >> worker-init.sh
printf "sudo " >> worker-init.sh
kubeadm token create --print-join-command >> worker-init.sh
chmod +x worker-init.sh