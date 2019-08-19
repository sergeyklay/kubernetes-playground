#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

apt-mark hold \
  linux-image-"$(uname -r)" \
  linux-modules-"$(uname -r)" \
  linux-modules-extra-"$(uname -r)" > /dev/null 2>&1 || true

echo 'Disable swap...'

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "Preliminary installation..."

apt-get --quiet --yes install python-apt > /dev/null 2>&1 || true
find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete
