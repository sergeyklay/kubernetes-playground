# -*- mode: ruby -*-
# vi: set ft=ruby :
# frozen_string_literal: true

Vagrant.require_version '>= 1.9.8'
require File.expand_path(File.dirname(__FILE__).to_s + '/src/helpers.rb')

VAGRANTFILE_API_VERSION ||= 2

# Define constants
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use vagrant-env plugin if available
  config.env.load('.env', '.env.dist') if plugin?('vagrant-env')

  # Manage cluster from the vagrant host:
  #   export EXPOSE_MASTER=true
  EXPOSE_MASTER = envb('EXPOSE_MASTER', true)

  # Bind the manager default kubernetes proxy port
  # to the vagrant host:
  #   export EXPOSE_PROXY=true
  EXPOSE_PROXY = envb('EXPOSE_PROXY', true)

  # Memory for the cluster's VMs:
  #   export NODE_MEMORY=2048
  NODE_MEMORY = envi('NODE_MEMORY', 2048)

  # CPUs for the cluster's VMs:
  #   export NODE_CPUS=2
  NODE_CPUS = envi('NODE_CPUS', 2)

  # Number of worker nodes to provision
  #   export NODE_WORKERS=2
  NODE_WORKERS = envi('NODE_WORKERS', 2)
end

# Base setup
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.box_check_update = false

  config.ssh.insert_key = false
  config.ssh.forward_agent = true
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Common provider-specific configuration
  config.vm.provider :virtualbox do |v|
    v.gui = false
    v.memory = NODE_MEMORY
    v.cpus = NODE_CPUS
    v.customize ['modifyvm', :id, '--vrde', 'off']
  end
end

# Bootstrap VM
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define 'bootstrap' do |bootstrap|
    bootstrap.vm.hostname = 'bootstrap.kp.vm'
    bootstrap.vm.network :private_network, ip: '192.168.77.9'
    bootstrap.vm.provision :hosts, sync_hosts: true if plugin?('vagrant-hosts')

    bootstrap.vm.provider :virtualbox do |v|
      v.memory = 384
      v.cpus = 1
      v.customize ['modifyvm', :id, '--name', 'bootstrap']
    end

    bootstrap.vm.provision :shell do |s|
      s.path = 'provisioning/bootstrap.sh'
    end
  end
end

# Master node
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define 'master', primary: true do |master|
    master.vm.hostname = 'master.kp.vm'
    master.vm.network :private_network, ip: '192.168.77.10'
    master.vm.provision :hosts, sync_hosts: true if plugin?('vagrant-hosts')

    # Bind kubernetes admin port so we can administrate from host
    master.vm.network :forwarded_port, guest: 6443, host: 6443 if EXPOSE_MASTER

    # Bind kubernetes default proxy port
    master.vm.network :forwarded_port, guest: 8001, host: 8001 if EXPOSE_PROXY

    master.vm.provider :virtualbox do |v|
      v.customize ['modifyvm', :id, '--name', 'master']
    end

    master.vm.provision :shell do |s|
      s.path = 'provisioning/node.sh'
    end
  end
end

# Worker nodes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  (1..NODE_WORKERS).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.hostname = "worker#{i}.kp.vm"
      worker.vm.network :private_network, ip: '192.168.77.' + (10 + i).to_s
      worker.vm.provision :hosts, sync_hosts: true if plugin?('vagrant-hosts')

      worker.vm.provider :virtualbox do |v|
        v.customize ['modifyvm', :id, '--name', "worker#{i}"]
      end

      worker.vm.provision :shell do |s|
        s.path = 'provisioning/node.sh'
      end
    end
  end
end
