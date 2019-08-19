# -*- mode: ruby -*-
# vi: set ft=ruby :
# frozen_string_literal: true

# Convenience helpers

def plugin?(plugin)
  Vagrant.has_plugin?(plugin)
end

def sync_hosts(box)
  box.vm.provision :hosts, sync_hosts: true if plugin?('vagrant-hosts')
end

def modifyvm(box, name, memory, cpus, descr)
  box.vm.provider :virtualbox do |v|
    v.customize ['modifyvm', :id, '--name', name]
    v.customize ['modifyvm', :id, '--memory', memory]
    v.customize ['modifyvm', :id, '--cpus', cpus]
    v.customize ['modifyvm', :id, '--description', descr]
  end
end

def envs(key, default)
  ENV[key] && !ENV[key].empty? ? ENV[key] : default
end

def envb(key, default)
  envs(key, default).to_s.downcase == 'true'
end

def envi(key, default)
  envs(key, default).to_i
end
