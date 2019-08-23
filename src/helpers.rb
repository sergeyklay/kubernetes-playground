# -*- mode: ruby -*-
# vi: set ft=ruby :
# frozen_string_literal: true

# Convenience helpers

def plugin?(plugin)
  Vagrant.has_plugin?(plugin)
end

def provisioned?(vm_name)
  File.exist?(".vagrant/machines/#{vm_name}/virtualbox/action_provision")
end

def ensure_ide_is_absent(provider, vm_name)
  return if provisioned?(vm_name)

  provider.customize [
    'storagectl', :id,
    '--name', 'IDE Controller',
    '--remove'
  ]
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
