#!/bin/bash
### Script for appending hostname to IP resolution to /etc/hosts
### for every Kubernetes node.


### Display usage information if not enought argumetns have been provided
if [ "$#" -ne 4 ]
then
  echo
  echo 'Usage: add-hosts <network_prefix> <master_count> <worker_count>'
  echo 'A simple bash utility to generate and append hostname mappings to an external file.'
  echo 
  echo 'Parameters:'
  echo '  network_prefix  /24 network prefix to append to all IP addresses ie. 10.0.2.'
  echo '  master_count    Number of master nodes in the cluster (1..9)'
  echo '  worker_count    Number of worker nodes in the cluster (1..9)'
  echo '  output          File to append the entries to it. /etc/hosts'
  echo 
  echo 'Example: add-hosts 192.168.2. 2 2'
  echo 'would setup a cluster with 1 load balancer, 2 master nodes and 2 worker nodes'
  echo 'and would append to /etc/hosts file the following lines:'
  echo '## Added by update-hosts.sh script from Vagrant'
  echo '192.168.2.10	lb'
  echo '192.168.2.11	master-1'
  echo '192.168.2.11	master-2'
  echo '192.168.2.21	worker-1'
  echo '192.168.2.22	worker-2'
  echo
  exit 1
fi


### Rename arguments for clarity
network_prefix=$1
master_count=$2
worker_count=$3
output=$4

lb_index=10
master_index=11
worker_index=21

echo >> $output
echo "## Added by add-hosts script from Vagrant" >> $output


### Write Load Balancer IP to hosts file
echo -e $network_prefix'10\tlb' | tee -a $output


### Write master IP range to hosts file
for ((i=0;i<$master_count;i++))
do
  ip=$network_prefix$((master_index + $i))
  host=master-$(($i+1))
  echo -e $ip'\t'$host | tee -a $output
done


### Write worker IP range to hosts file
for ((i=0;i<$worker_count;i++))
do
  ip=$network_prefix$((worker_index + $i))
  host=worker-$(($i+1))
  echo -e $ip'\t'$host | tee -a $output
done