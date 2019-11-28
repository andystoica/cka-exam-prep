# Node deployment with Vagrant and VirtualBox

- [Cluster Description](#cluster-description)
- [Installation](#installation)
- [General methodology](#general-methodology)

---

## Cluster Description

This preparatory section describes the cluster node setup and requirements. There will be 6 VM nodes in total, deployed with Vagrant on top of VirtualBox. Nodes are as follows:

    Load Balancer Node    lb          192.168.2.10
    Master Node 1         master-1    192.168.2.11
    Master Node 2         master-2    192.168.2.12
    Worker Node 1         worker-1    192.168.2.21
    Worker Node 2         worker-2    192.168.2.22 

The **lb** node provides a common entry point for both API servers running in an HA configuration on the two master nodes. It uses haproxy to balance the traffic between the two API endpoints.

**Master** nodes are setup in a HA configuration, both for the etcd data store as well as the Kubernetes Control Plane. Is worth noting that in practice you would need a minimum of 3 master nodes to maintain quorum in the event of a master node failure. We stick with 2 master nodes for this exercise to keep the resource usage under control. The process for setting up additional master nodes is the same.

**Worker** nodes will be joined to the cluster by issuing manual certificates like the rest of the control plane components.

---

## Installation

This guide assumes a working Vagrant / VirtualBox is already configured on the machine. The next step is to clone the repository to a local folder and execute the `vagranta up` command.

The script will:

- deploy the 6 VMs in sequence
- update the /etc/hosts file with all nodes in the cluster (/scripts/update-hosts.sh)
- install and configure Docker for Kubernetes (/scripts/install-docker.sh)
- setup a common shared sirectory on all nodes to facilitate file sharing (~/share)

If at any time you need to start fresh, you can simply destroy the cluster with `vagrant destroy -f` and bring it back up with `vagrant up`. This will completely remove all the VMs and their associated files but will not delete the content of the /share folder. You may want to clear this folder manually for a clean start.

---

## General methodology

The process requires generating and installing a number of files into their correct locations. Their types fit broadly into several categories:

- certificate files (.crt, .key)
- auth configuration files (.kubeconfig)
- other configuration files (.yaml)
- binary files

Because some files are shared by multiple nodes, they will be generated on a single machine inside the ~/share folder. Other files are specific to each node as they reffer to a node's own IP address and / or host name. These files will be generated on those machines.

A word of caution. To save time, some commands can be executed in parallel across several nodes using `tmux` or input broadcasting feature in `iTerm2`. You need to be careful particularly when generating common certificate files as such commands run in parallel may produce invalid private/public key pairs.

By convention, common files shared by multiple machines, will be generated on the **LB node** under `~/share/` while unique files and commands which can be generated or run in parallel, will be executed on the **master / worker nodes** as appropriate.

Each script will be preceeded with a label indicating where the commands should be entered.

    LB NODE ↴

```bash
{

# These commands to be executed once
# on the LB node
cd ~/share

}
```

    MASTER NODE(s) ↴

```bash
{

# These commands can be executed in parallel
# on all MASTER nodes
cd ~/share

}
```

    WORKER NODE(s)  ↴

```bash
{

# These commands can be executed in parallel
# on all WORKER nodes
cd ~/share

}
```
