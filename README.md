# Multihost Virtual Machine Provisioning powered by Vagrant

A skeleton repository that considerably simplifies setting up a
multi VM Kubernetes cluster with a VirtualBox Virtual Machine development
environment powered by Vagrant and different provisioners like Shell and
Ansible.

_This project is designed for local development only._

## Architecture

This project allows you to create a Kubernetes cluster with 3 nodes which contains
the components below:

| IP            | Hostname       | Components                               |
| ------------- | -------------- | ---------------------------------------- |
| 192.168.77.10 | `bootstrap.vm` | Bootstrap machine to run provision on Kubernetes cluster |
| 192.168.77.11 | `kubeadm.vm`   | `kube-apiserver`, `kube-controller-manager`, `kube-addon-manager`, `kube-scheduler`, `etcd`, `kubelet`, `kubeadm`, `kubctl`, `docker`, `dashboard`, `weave-net` |
| 192.168.77.12 | `worker-1.vm`  | `kubelet`, `kubeadm`, `kubctl`, `docker` |
| 192.168.77.13 | `worker-2.vm`  | `kubelet`, `kubeadm`, `kubctl`, `docker` |

## Prerequisites

- [VirtualBox](https://virtualbox.org/)
- [Vagrant](https://vagrantup.com/)

## Getting started

After having done the adjustments you can startup and provision your
whole VM environment with a simple:

```bash
vagrant up
```

After initial provision go to `bootstrap.vm` host and run ansible provision:

```bash
vagrant ssh bootstrap.vm
cd /vagrant/provisioning
ansible-playbook -i hosts playbook.yml
```

Then setup Kubernetes cluster:

```bash
vagrant ssh kubeadm.vm
sudo kubeadm init \
  --apiserver-advertise-address 192.168.77.11 \
  --pod-network-cidr=192.168.0.0/16

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
D="https://raw.githubusercontent.com/kubernetes/dashboard"
kubectl apply -f "$D/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml"
```

Add nodes:
```bash
# use "token" and "discovery token" from previous response at "kubeadm.vm" node
vagrant ssh worker-1.vm
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

By default, your cluster will not schedule pods on the control-plane node for security reasons.
If you want to be able to schedule workloads for, run:

```bash
vagrant ssh kubeadm.vm
kubectl taint nodes --all node-role.kubernetes.io/master-
```

With output looking something like:

```
node/kubeadm.vm untainted
taint "node-role.kubernetes.io/master:" not found
taint "node-role.kubernetes.io/master:" not found
```

This will remove the `node-role.kubernetes.io/master` taint from any nodes that have it,
including the control-plane node, meaning that the scheduler will then be able to schedule pods everywhere.

At this point you should have a fully-functional kubernetes cluster on which you can run workloads.

## Test the installation:

```bash
vagrant ssh kubeadm.vm

kubectl cluster-info

# You will  response like this:
# Kubernetes master is running at https://192.168.77.11:6443
# KubeDNS is running at https://192.168.77.11:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
#
# To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

kubectl get pods --all-namespaces

# You will  response like this:
#
# NAMESPACE     NAME                                    READY   STATUS    RESTARTS   AGE
# kube-system   coredns-5c98db65d4-nxjr7                1/1     Running   0          3m27s
# kube-system   coredns-5c98db65d4-q2h7n                1/1     Running   0          3m27s
# kube-system   etcd-kubeadm.vm                         1/1     Running   0          2m26s
# kube-system   kube-addon-manager-kubeadm.vm           1/1     Running   0          3m46s
# kube-system   kube-apiserver-kubeadm.vm               1/1     Running   0          2m51s
# kube-system   kube-controller-manager-kubeadm.vm      1/1     Running   0          2m42s
# kube-system   kube-proxy-6zdss                        1/1     Running   0          3m28s
# kube-system   kube-scheduler-kubeadm.vm               1/1     Running   0          2m41s
# kube-system   kubernetes-dashboard-7d75c474bb-77l85   1/1     Running   0          34s
# kube-system   weave-net-wkbt9                         2/2     Running   0          43s

kubectl get nodes

# You will  response like this:
#
# NAME          STATUS   ROLES    AGE     VERSION
# kubeadm.vm    Ready    master   17m     v1.15.2
# worker-1.vm   Ready    <none>   6m19s   v1.15.2
# worker-2.vm   Ready    <none>   5m21s   v1.15.2
```

## License

This project is open source software licensed under the MIT Licence.
For more see LICENSE.txt file.
