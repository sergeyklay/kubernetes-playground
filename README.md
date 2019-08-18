# Multihost Virtual Machine Provisioning powered by Vagrant

A skeleton repository that considerably simplifies setting up a
multihost project with a VirtualBox Virtual Machine development
environment powered by Vagrant and different provisioners like File,
Shell and Ansible.

## Prerequisites

- [VirtualBox](https://virtualbox.org/)
- [Vagrant](https://vagrantup.com/)
- Vagrant Plugins
  - vagrant-vbguest


## Getting started

After having done the adjustments you can startup and provision your
whole VM environment with a simple

```bash
vagrant up
```

After provision go to `bootstrap.vm` host and run ansible provision:

```bash
vagrant ssh bootstrap.vm
cd  /vagrant/ansible
ansible-playbook -i hosts playbook.yml
```

Then setup Kubernetes cluster:

```bash
vagrant ssh kubeadm.vm
sudo kubeadm init --apiserver-advertise-address 192.168.77.11

# NOTE:
# At this moment save "token" and "discovery-token-ca-cert-hash"
# from response

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Optionally install CNI plugins:

```bash
vagrant ssh kubeadm.vm

# Weave Net
V="$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$V"

# Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

# check
kubectl get pods --all-namespaces
```

Add nodes:
```bash
# use "token" and "discovery token" from previous response at "kubeadm.vm" node
vagrant ssh node1.vm
sudo kubeadm join 192.168.77.11:6443 --token "token" \
    --discovery-token-ca-cert-hash "discovery token" \
    --ignore-preflight-errors=all
```

```bash
# use "token" and "discovery token" from previous response at "kubeadm.vm" node
vagrant ssh node2.vm
sudo kubeadm join 192.168.77.11:6443 --token "token" \
    --discovery-token-ca-cert-hash "discovery token" \
    --ignore-preflight-errors=all
```

```bash
# check
vagrant ssh kubeadm.vm
kubectl get pods --all-namespaces
```
