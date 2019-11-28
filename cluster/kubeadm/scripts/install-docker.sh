#!/bin/bash
### Script for installing latest compatible version of Docker 18.06
### Adds the required repositories and isntalls the correct packages
### Configures the Docker daemon for compatibility with Kubernetes


### Set up the repository and install packages to allow apt to use a repository over HTTPS
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"


### Install Docker CE
apt-get update
apt-get install -y docker-ce=18.06.3~ce~3-0~ubuntu
apt-mark hold docker


### Configure Docker daemon to work with Kubernetes
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

systemctl daemon-reload
systemctl restart docker


### Allow bridge traffic
sysctl net.bridge.bridge-nf-call-iptables=1


### Add vagrant user to docker group
usermod -aG docker vagrant
