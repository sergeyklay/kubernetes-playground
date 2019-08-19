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
- vagrant-scp

## Getting started

After having done the adjustments you can startup and provision your
whole VM environment with a simple:

```shell script
vagrant up
```

After initial provision go to `bootstrap` VM and run ansible provision:

```shell script
vagrant ssh bootstrap
cd /vagrant/provisioning
ansible-playbook -i hosts playbook.yml
```

Then setup Kubernetes cluster using `kubeadm` VM:

```shell script
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

```shell script
vagrant ssh kubeadm

# Installing a pod network add-on
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml

# Dashboard
RAW="https://raw.githubusercontent.com"
kubectl apply -f "$RAW/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml"
```

## Control plane node isolation

By default, your cluster will not schedule pods on the control-plane node for security reasons.
To be able schedule workloads, run:

```shell script
vagrant ssh kubeadm
kubectl taint nodes --all node-role.kubernetes.io/master-
```

This will With output looking something like:

```
node/kubeadm.vm untainted
taint "node-role.kubernetes.io/master:" not found
taint "node-role.kubernetes.io/master:" not found
```

This will remove the `node-role.kubernetes.io/master` taint from any nodes that have it,
including the control-plane node, meaning that the scheduler will then be able to schedule pods everywhere.


## Joining your nodes

The nodes are where your workloads (containers and pods, etc) run.
To add new nodes to your cluster do the following for each VM (`worker-1`, `worker-2`, etc):

```shell script
# use "token" and "discovery token" from previous response at "kubeadm" VM
sudo kubeadm join 192.168.77.10:6443 --token "token" \
    --discovery-token-ca-cert-hash "discovery token" \
    --ignore-preflight-errors=all
```

## Test the installation:

```shell script
vagrant ssh kubeadm

kubectl cluster-info

# You will  response like this:
# Kubernetes master is running at https://192.168.77.10:6443
# KubeDNS is running at https://192.168.77.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
#
# To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

kubectl get pods --all-namespaces

# You will see response like this:
#
# NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
# kube-system   calico-kube-controllers-65b8787765-m27hw   1/1     Running   0          7m7s
# kube-system   calico-node-6lnnz                          1/1     Running   0          3m21s
# kube-system   calico-node-l6bsn                          1/1     Running   0          7m7s
# kube-system   calico-node-zbpp6                          1/1     Running   0          4m5s
# kube-system   coredns-5c98db65d4-g5gfd                   1/1     Running   0          13m
# kube-system   coredns-5c98db65d4-rvmhw                   1/1     Running   0          13m
# kube-system   etcd-kubeadm.vm                            1/1     Running   0          12m
# kube-system   kube-addon-manager-kubeadm.vm              1/1     Running   0          13m
# kube-system   kube-apiserver-kubeadm.vm                  1/1     Running   0          12m
# kube-system   kube-controller-manager-kubeadm.vm         1/1     Running   0          12m
# kube-system   kube-proxy-4lb8w                           1/1     Running   0          4m5s
# kube-system   kube-proxy-4sjfh                           1/1     Running   0          13m
# kube-system   kube-proxy-ptbcx                           1/1     Running   0          3m21s
# kube-system   kube-scheduler-kubeadm.vm                  1/1     Running   0          12m
# kube-system   kubernetes-dashboard-7d75c474bb-sxqdv      1/1     Running   0          6m53s

kubectl get nodes

# You will see response like this:
#
# NAME          STATUS   ROLES    AGE     VERSION
# kubeadm.vm    Ready    master   17m     v1.15.2
# worker-1.vm   Ready    <none>   6m19s   v1.15.2
# worker-2.vm   Ready    <none>   5m21s   v1.15.2

kubectl get services --all-namespaces

# You will see response like this:
#
# NAMESPACE     NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
# default       kubernetes             ClusterIP   10.96.0.1       <none>        443/TCP                  21m
# kube-system   kube-dns               ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   21m
# kube-system   kubernetes-dashboard   ClusterIP   10.102.203.67   <none>        443/TCP                  19m
```

At this point you should have a fully-functional kubernetes cluster on which you can run workloads.

If you want to connect to the API Server from outside the cluster (e.g. your local workstation)
you must create a secure channel to your Kubernetes cluster:

```shell script
# To use "vagrant scp" install vagrant-scp plugin
vagrant scp kubeadm:/home/vagrant/.kube/config ./admin.conf
kubectl --kubeconfig ./admin.conf proxy --port=8002 --accept-hosts='^*$'
```

Now access Dashboard at:

[`http://localhost:8002/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`](
http://localhost:8002/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/).

## License

This project is open source software licensed under the MIT Licence.
For more see LICENSE.txt file.
