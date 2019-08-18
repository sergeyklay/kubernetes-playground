#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

export DEBIAN_FRONTEND=noninteractive

echo "Preliminary installation..."

apt-get update --quiet --yes > /dev/null 2>&1 || true
apt-get --quiet --yes --fix-missing install python-pip sshpass curl > /dev/null 2>&1 || true
curl -sSL https://bootstrap.pypa.io/get-pip.py | python > /dev/null 2>&1 || true
pip install --quiet --no-color ansible

echo "Configuring Ansible..."

cat /vagrant/ansible/resources/.ansible.cfg > /home/vagrant/.ansible.cfg
chown vagrant:vagrant /home/vagrant/.ansible.cfg
chmod go-r /home/vagrant/.ansible.cfg

echo "Configuring ssh..."

mkdir -p /home/vagrant/.ssh
touch /home/vagrant/.ssh/authorized_keys
cat /vagrant/ansible/resources/config > /home/vagrant/.ssh/config
chown vagrant:vagrant /home/vagrant/.ssh/*
chmod go-r /home/vagrant/.ssh/*

echo "Set hostname properly..."

hostname "$(hostname | cut -d. -f1)".vm

echo "Cleanup..."

apt-get autoremove --quiet --yes
apt-get autoclean --quiet --yes
