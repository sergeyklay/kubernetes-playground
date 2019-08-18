# -*- mode: ruby -*-
# vi: set ft=ruby :
# frozen_string_literal: true

boxes = [
  {
    name: 'bootstrap.vm',
    desc: 'Bootstrap machine to provision Kubernetes cluster',
    ip: '192.168.77.10',
    mem: 512,
    vrde: 'off',
    cpu: 1,
    prsn: {
      name: 'Install ansible',
      code: 'ansible/install.sh'
    }
  },
  {
    name: 'kubeadm.vm',
    desc: 'Master node for Kubernetes cluster',
    ip: '192.168.77.11',
    mem: 2000,
    vrde: 'off',
    cpu: 2,
    prsn: {
      name: 'Initial setup',
      code: 'ansible/setup.sh'
    }
  },
  {
    name: 'node1.vm',
    desc: 'A regular node for Kubernetes cluster',
    ip: '192.168.77.12',
    mem: 2000,
    vrde: 'off',
    cpu: 2,
    prsn: {
      name: 'Initial setup',
      code: 'ansible/setup.sh'
    }
  },
  {
    name: 'node2.vm',
    desc: 'A regular node for Kubernetes cluster',
    ip: '192.168.77.13',
    mem: 2000,
    vrde: 'off',
    cpu: 2,
    prsn: {
      name: 'Initial setup',
      code: 'ansible/setup.sh'
    }
  }
]

VAGRANTFILE_API_VERSION ||= 2
Vagrant.require_version '>= 1.9.8'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.box_check_update = false

  # always use Vagrants insecure key
  config.ssh.insert_key = false

  # forward ssh agent to easily ssh into the different machines
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
        v.customize ['modifyvm', :id, '--vrde', (box[:vrde]).to_s]
      end

      machine.vm.provision :shell do |s|
        s.name = box[:prsn][:name]
        s.path = box[:prsn][:code]
      end
    end
  end
end