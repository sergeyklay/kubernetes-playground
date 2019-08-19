#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

swapoff -a
sysctl -w vm.swappiness=0

apt-mark hold \
  linux-image-"$(uname -r)" \
  linux-modules-"$(uname -r)" \
  linux-modules-extra-"$(uname -r)" > /dev/null 2>&1 || true

echo "Preliminary installation..."

apt-get --quiet --yes install python-apt > /dev/null 2>&1 || true
