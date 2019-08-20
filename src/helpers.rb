# -*- mode: ruby -*-
# vi: set ft=ruby :
# frozen_string_literal: true

# Convenience helpers

def plugin?(plugin)
  Vagrant.has_plugin?(plugin)
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
