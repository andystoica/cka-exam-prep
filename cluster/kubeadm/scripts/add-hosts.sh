#!/bin/bash
### Script for appending hostname to IP resolution to /etc/hosts
### for every Kubernetes node.


### Display usage information if not enought argumetns have been provided
if [ "$#" -ne 5 ]
then
  echo
  echo 'Usage: add-hosts <network_prefix> <start_index> <count> <hostname_prefix> <output'
  echo 'A simple bash utility to generate and append hostname mappings to an external file.'
  echo 
  echo 'Parameters:'
  echo '  network_prefix  /24 network prefix to append to all IP addresses ie. 10.0.2.'
  echo '  start_index     Index to start counting from'
  echo '  count           Number of sequential hosts mappings to generate'
  echo '  hostname_prefix Partial hostname prefix to prepend to every hostname entry'
  echo '  output          File to append the entries to it. /etc/hosts'
  echo 
  echo 'Example: add-hosts 10.0.2. 21 3 worker- /etc/hosts'
  echo 'would append to /etc/hosts file the following lines:'
  echo '10.0.2.21	worker-1'
  echo '10.0.2.22	worker-2'
  echo '10.0.2.23	worker-3'
  echo
  exit 1
fi


### Rename arguments for more clarity
network_prefix=$1
start_index=$2
count=$3
hostname_prefix=$4
output=$5

echo >> $output
echo "## Added by add-hosts script from Vagrant" >> $output


### Write masters host files
for ((i=0;i<$count;i++))
do
  ip=$network_prefix$(($start_index + $i))
  host=$hostname_prefix$(($i+1))
  echo -e $ip'\t'$host | tee -a $output
done