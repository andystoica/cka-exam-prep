### Define the base image and IP network
BOX_IMAGE = "ubuntu/xenial64"     # Base image to be used for provisioning all VMs
IP_NW = "192.168.2."              # Private network range to be assigned to each VM

### Define Master Nodes
NUM_MASTER_NODE = 1               # Number of master nodes to be provisioned
MASTER_NODE_PREFIX = "master-"    # Hostname prefix for master nodes
MASTER_IP_START = 11              # First assignable IP in the network range
MASTER_CPU = 2                    # Amount of CPU units to be allocated
MASTER_MEMORY = 2048              # Amount of RAM to be allocated in MB

### Define Worker Nodes
NUM_WORKER_NODE = 2               # Number of worker nodes to be provisioned
WORKER_NODE_PREFIX = "worker-"    # Hostname prefix for worker nodes
WORKER_IP_START = 21              # First assignable IP in the network range
WORKER_CPU = 1                    # Amount of CPU units to be allocated
WORKER_MEMORY = 1024              # Amount of RAM to be allocated in MB


Vagrant.configure("2") do |config|

  config.vm.box = BOX_IMAGE
  config.vm.box_check_update = false
  config.vm.synced_folder "./init", "/home/vagrant/init"
  config.vm.synced_folder "./test", "/home/vagrant/test"

  
  ### Provision MASTER Nodes
  (1..NUM_MASTER_NODE).each do |i|
      config.vm.define "#{MASTER_NODE_PREFIX}#{i}" do |node|
        
        ### VirtualBox GUI settings
        node.vm.provider "virtualbox" do |vb|
            vb.name = "k8s-#{MASTER_NODE_PREFIX}#{i}-ubuntu"
            vb.cpus = MASTER_CPU
            vb.memory = MASTER_MEMORY
        end
        
        # Assign host name and IP address
        node.vm.hostname = "#{MASTER_NODE_PREFIX}#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i - 1}"
        
        node.vm.provision "Master nodes hostnames",
          type: "shell",
          path: "scripts/add-hosts.sh",
          args: [IP_NW, MASTER_IP_START, NUM_MASTER_NODE, MASTER_NODE_PREFIX, '/etc/hosts']
        node.vm.provision "Worker nodes hostnames",
          type: "shell",
          path: "scripts/add-hosts.sh",
          args: [IP_NW, WORKER_IP_START, NUM_WORKER_NODE, WORKER_NODE_PREFIX, '/etc/hosts']        
        node.vm.provision "Install Docker",
          type: "shell",
          path: "scripts/install-docker.sh"
        node.vm.provision "Install Kubernetes",
          type: "shell",
          path: "scripts/install-k8s.sh"
      end
  end
  
  
  ### Provision WORKER Nodes
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "#{WORKER_NODE_PREFIX}#{i}" do |node|
      
      ### VirtualBox GUI settings
      node.vm.provider "virtualbox" do |vb|
          vb.name = "k8s-#{WORKER_NODE_PREFIX}#{i}-ubuntu"
          vb.cpus = WORKER_CPU
          vb.memory = WORKER_MEMORY
      end
      
      # Assign host name and IP address
      node.vm.hostname = "#{WORKER_NODE_PREFIX}#{i}"
      node.vm.network :private_network, ip: IP_NW + "#{WORKER_IP_START + i - 1}"
      
      # Add master and worker hostsnames to /etc/hosts file
      node.vm.provision "Master nodes hostnames", 
        type: "shell",
        path: "scripts/add-hosts.sh",
        args: [IP_NW, MASTER_IP_START, NUM_MASTER_NODE, MASTER_NODE_PREFIX, '/etc/hosts']
      node.vm.provision "Worker nodes hostnames",
        type: "shell",
        path: "scripts/add-hosts.sh",
        args: [IP_NW, WORKER_IP_START, NUM_WORKER_NODE, WORKER_NODE_PREFIX, '/etc/hosts']        
      
      # Install Docker and Kubernetes packages
      node.vm.provision "Install Docker",
        type: "shell",
        path: "scripts/install-docker.sh"
      node.vm.provision "Install Kubernetes",
        type: "shell",
        path: "scripts/install-k8s.sh"
    end
  end
  
end