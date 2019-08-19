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
| 192.168.77.9  | `bootstrap.vm` | Bootstrap machine to run provision on Kubernetes cluster |
| 192.168.77.10 | `kubeadm.vm`   | `kube-apiserver`, `kube-controller-manager`, `kube-addon-manager`, `kube-scheduler`, `etcd`, `kubelet`, `kubeadm`, `kubctl`, `docker`, `dashboard`, `weave-net` |
| 192.168.77.11 | `worker-1.vm`  | `kubelet`, `kubeadm`, `kubctl`, `docker` |
| 192.168.77.12 | `worker-2.vm`  | `kubelet`, `kubeadm`, `kubctl`, `docker` |

## Prerequisites

- [VirtualBox](https://virtualbox.org/)
- [Vagrant](https://vagrantup.com/)

Recommended Vagrant Plugins

- vagrant-vbguest
- vagrant-hosts
- vagrant-env

## Getting started

After having done the adjustments you can startup and provision your
whole VM environment with a simple:

```bash
vagrant up
```

After initial provision go to `bootstrap` VM and run ansible provision:

```bash
vagrant ssh bootstrap
cd /vagrant/provisioning
ansible-playbook -i hosts playbook.yml
```

Then setup Kubernetes cluster using `kubeadm` VM:

```bash
vagrant ssh kubeadm
sudo kubeadm init \
  --apiserver-advertise-address 192.168.77.10 \
  --pod-network-cidr=192.168.0.0/16

# NOTE:
# At this moment save "token" and "discovery-token-ca-cert-hash"
# from response

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Optionally install CNI plugins using `kubeadm` VM:

```bash
vagrant ssh kubeadm

# Weave Net
V="$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$V"

# Dashboard
D="https://raw.githubusercontent.com/kubernetes/dashboard"
kubectl apply -f "$D/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml"
```

Add nodes:
```bash
# use "token" and "discovery token" from previous response at "kubeadm" VM
vagrant ssh worker-1
sudo kubeadm join 192.168.77.10:6443 --token "token" \
    --discovery-token-ca-cert-hash "discovery token" \
    --ignore-preflight-errors=all
```

```bash
# use "token" and "discovery token" from previous response at "kubeadm" VM
vagrant ssh worker-2
sudo kubeadm join 192.168.77.10:6443 --token "token" \
    --discovery-token-ca-cert-hash "discovery token" \
    --ignore-preflight-errors=all
```

By default, your cluster will not schedule pods on the control-plane node for security reasons.
If you want to be able to schedule workloads for, run:

```bash
vagrant ssh kubeadm
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
vagrant ssh kubeadm

kubectl cluster-info

# You will  response like this:
# Kubernetes master is running at https://192.168.77.10:6443
# KubeDNS is running at https://192.168.77.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
#
# To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

kubectl get pods --all-namespaces

# You will  response like this:
#
# NAMESPACE     NAME                                    READY   STATUS    RESTARTS   AGE
# kube-system   coredns-5c98db65d4-vmlt5                1/1     Running   0          6m14s
# kube-system   coredns-5c98db65d4-z66d5                1/1     Running   0          6m14s
# kube-system   etcd-kubeadm.vm                         1/1     Running   0          5m31s
# kube-system   kube-addon-manager-kubeadm.vm           1/1     Running   0          6m33s
# kube-system   kube-apiserver-kubeadm.vm               1/1     Running   0          5m17s
# kube-system   kube-controller-manager-kubeadm.vm      1/1     Running   0          5m20s
# kube-system   kube-proxy-6l9b6                        1/1     Running   0          66s
# kube-system   kube-proxy-kc7j8                        1/1     Running   0          110s
# kube-system   kube-proxy-qsqqb                        1/1     Running   0          6m14s
# kube-system   kube-scheduler-kubeadm.vm               1/1     Running   0          5m36s
# kube-system   kubernetes-dashboard-7d75c474bb-4pl7l   1/1     Running   0          4m13s
# kube-system   weave-net-74m69                         2/2     Running   1          110s
# kube-system   weave-net-qnkm5                         2/2     Running   0          4m20s
# kube-system   weave-net-vgnj4                         2/2     Running   0          66s

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
