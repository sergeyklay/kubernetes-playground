# -*- mode: ruby -*-
# vi: set ft=ruby :
# frozen_string_literal: true

boxes = [
  {
    name: 'bootstrap.vm',
    desc: 'Bootstrap machine to run provision on Kubernetes cluster',
    ip: '192.168.77.10',
    mem: 512,
    cpu: 1,
    shell: 'ansible/bootstrap.sh'
  },
  {
    name: 'kubeadm.vm',
    desc: 'Master node for Kubernetes cluster',
    ip: '192.168.77.11',
    mem: 2048,
    cpu: 2,
    shell: 'ansible/node.sh'
  },
  {
    name: 'worker-1.vm',
    desc: 'Worker node for Kubernetes cluster',
    ip: '192.168.77.12',
    mem: 2048,
    cpu: 2,
    shell: 'ansible/node.sh'
  },
  {
    name: 'worker-2.vm',
    desc: 'Worker node for Kubernetes cluster',
    ip: '192.168.77.13',
    mem: 2048,
    cpu: 2,
    shell: 'ansible/node.sh'
  }
]

VAGRANTFILE_API_VERSION ||= 2
Vagrant.require_version '>= 1.9.8'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.box_check_update = false

  config.ssh.insert_key = false
  config.ssh.forward_agent = true
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  boxes.each do |box|
    config.vm.define box[:name] do |machine|
      machine.vm.hostname = (box[:name]).to_s
      machine.vm.network :private_network, ip: box[:ip]

      machine.vm.provider :virtualbox do |v|
        v.gui = false

        v.customize ['modifyvm', :id, '--name', (box[:name]).to_s]
        v.customize ['modifyvm', :id, '--description', (box[:desc]).to_s]
        v.customize ['modifyvm', :id, '--memory', box[:mem]]
        v.customize ['modifyvm', :id, '--cpus', box[:cpu]]
        v.customize ['modifyvm', :id, '--vrde', 'off']
      end

      machine.vm.provision :shell do |s|
        s.name = "Initial #{box[:name]} setup ..."
        s.path = box[:shell]
      end
    end
  end
end
