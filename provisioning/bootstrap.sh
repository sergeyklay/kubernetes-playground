#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

export DEBIAN_FRONTEND=noninteractive

apt-mark hold \
  linux-image-"$(uname -r)" \
  linux-modules-"$(uname -r)" \
  linux-modules-extra-"$(uname -r)" > /dev/null 2>&1 || true

echo "Preliminary installation..."

apt-get update --quiet --yes > /dev/null 2>&1 || true
apt-get upgrade --quiet --yes > /dev/null 2>&1 || true

apt-get --quiet --yes --fix-missing install sshpass curl > /dev/null 2>&1 || true
curl -sSL https://bootstrap.pypa.io/get-pip.py | /usr/bin/python3 > /dev/null 2>&1 || true
pip install --quiet --no-color ansible
chown -R vagrant:vagrant /home/vagrant/.cache

echo "Configuring ssh..."

mkdir -p /home/vagrant/.ssh
touch /home/vagrant/.ssh/authorized_keys
cat >/home/vagrant/.ssh/config <<EOL
Host *
  IdentitiesOnly=yes
EOL
chown vagrant:vagrant /home/vagrant/.ssh/*
chmod go-r /home/vagrant/.ssh/*

echo "Configure Ansible..."

mkdir -p /etc/ansible
cp /vagrant/provisioning/resources/ansible.cfg /etc/ansible/ansible.cfg

echo "Set hostname properly..."

hostname "$(hostname | cut -d. -f1)".vm

echo "Cleanup..."

apt-get autoremove --quiet --yes
apt-get autoclean --quiet --yes
