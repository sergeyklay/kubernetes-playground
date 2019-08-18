#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

swapoff -a
sysctl -w vm.swappiness=0
apt-get --quiet --yes install linux-headers-$(uname -r) > /dev/null 2>&1 || true
