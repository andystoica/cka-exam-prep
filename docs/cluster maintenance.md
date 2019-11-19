# Cluster maintenance

- [1. Kubernetes cluster upgrade process](#1-kubernetes-cluster-upgrade-process)
  - [1.1. Upgrade a running cluster with Kubeadm](#11-upgrade-a-running-cluster-with-kubeadm)
- [2. OS Upgrades](#2-os-upgrades)
- [3. Backup and restore methodologies](#3-backup-and-restore-methodologies)

## 1. Kubernetes cluster upgrade process

The API is the leader component and must be upgraded first. Control plane components like control-manager and scheduler can be 1 minor version behind. Kubled and Kube-proxy can be 2 minor versions behind. Kubectl can be either ahead or behind by one minor version in relation to the API.

Kuberneted supports the current plus 2 previous minor versions.

### 1.1. Upgrade a running cluster with Kubeadm

The process upgrades the core component of the Kubernetes cluster. etcd and CoreDNS are not part of the upgrade process. We start by inspecting the cluster component current and available versions.

```bash
# show current and available versions for control plane components
kubeadm upgrade plan
```

Upgrade the **MASTER** Node.

```bash
# upgrade the kubeadm tool and kubectl
apt-get install -y kubeadm=1.12.0-00
apt-get install -y kubectl=1.12.0-00

# use kubeadm to upgrade the control plane components running as pods
# (apiserver, controller-manager, sheduler, kube-proxy)
kubeadm upgrade apply v1.12.0

# manualy upgrade and restart kubelet
apt-get install -y kubelet=1.12.0-00
systemctl restart kubelet

# verify the upgrade
kubeadm upgrade plan
kubectl get nodes
```

Upgrade each of the **WORKER** Nodes

```bash
# (MASTER) drain and cordon the node
kubectl drain node01 --ignore-daemonsets

# (WORKER) manually upgrade the kubeadm tool, kublet and reload configuration
apt-get install -y kubeadm=1.12.0-00
apt-get install -y kubelet=1.12.0-00
kubeadm upgrade node config --kubelet-version v1.12.0
systemctl restart kubelet

# (MASTER) verify upgrade and uncordon the node
kubectl get nodes
kubectl uncordon node01
```

## 2. OS Upgrades

The process involves relocating the running pods onto different nodes and cordoning the node under maintenance. When maintenance is complete, uncordon the node to allow pods to be scheduled on it.

```bash
# cordon the node and redistribute running pods to other nodes
kubectl drain node02 --ignore-daemonsets
# perform maintenance tasks
# ...
# bring the node back to service
kubeclt uncordon node02
```

To temporarly prevent new pods from being scheduled on a particular node

```bash
kubectl cordon node01
```

## 3. Backup and restore methodologies
