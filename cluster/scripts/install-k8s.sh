#!/bin/bash
### Install Kubernetes comoponents to all nodes
### Add the required repositories and installed the correct packages
### Marks K8s componentes to prevent unintentioanl upgrades


### Setup repositories and install packages to allow apt to use a repository over HTTPS
apt-get update
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF


### Install kubles kubeadm and kubectl
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl