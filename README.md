# Multihost Virtual Machine Provisioning powered by Vagrant

A skeleton repository that considerably simplifies setting up a
multi VM Kubernetes cluster with a VirtualBox Virtual Machine development
environment powered by Vagrant and different provisioners like Shell and
Ansible.

_This project is designed for local development only._

## Architecture

This project allows you to create a Kubernetes cluster with control-plane node (which controls the cluster),
and two (by default) worker nodes (where your workloads, like Pods and Deployments run).
Components used by default are provided below:

| IP            | Hostname      | Components                                                |
| ------------- | ------------- | --------------------------------------------------------- |
| 192.168.77.9  | `ctl.k8s`     | Ansible Controller to run provision on Kubernetes cluster |
| 192.168.77.10 | `master.k8s`  | `kube-apiserver`, `kube-controller-manager`, `kube-scheduler`, `etcd`, `kubelet`, `kubeadm`, `kubctl`, `docker-ce` |
| 192.168.77.11 | `worker1.k8s` | `kubelet`, `kubeadm`, `docker-ce`                         |
| 192.168.77.12 | `worker2.k8s` | `kubelet`, `kubeadm`, `docker-ce`                         |

Add-ons on control plane are:

- [Addon-manager](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/addon-manager)
- [Dashboard](https://github.com/kubernetes/dashboard/)
- [Calico](https://docs.projectcalico.org/)

## Prerequisites

- [VirtualBox](https://virtualbox.org/) >= 5.2
- [Vagrant](https://vagrantup.com/) >= 2.2

Recommended Vagrant Plugins

- vagrant-vbguest
- vagrant-env
- vagrant-scp

## Getting started

After having done the adjustments you can startup and provision your
whole VM environment with a simple:

```shell script
vagrant up
```

## Configure `kubectl`

To use [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) at your local workstation
run commands as follows:

```shell script
mkdir -p $HOME/.kube
vagrant scp master:/home/vagrant/.kube/config $HOME/.kube/config
```

Notice, to use `vagrant scp` command you'll need install `vagrant-scp` plugin.
Another way to obtain config is to use `scp` as follows:

```shell script
# use "vagrant" passowrd
scp vagrant@192.168.77.10:/home/vagrant/.kube/config $HOME/.kube/config
```

## Test the installation

```shell script
kubectl cluster-info

# You will  response like this:
#
# Kubernetes master is running at https://192.168.77.10:6443
# KubeDNS is running at https://192.168.77.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
#
# To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

kubectl get pods --all-namespaces

# You will see response like this:
#
# NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
# kube-system   calico-kube-controllers-65b8787765-lvn9s   1/1     Running   0          3m42s
# kube-system   calico-node-5qb6d                          0/1     Running   0          27s
# kube-system   calico-node-jfhfn                          1/1     Running   0          57s
# kube-system   calico-node-tvrtv                          1/1     Running   0          3m42s
# kube-system   coredns-5c98db65d4-5jq5s                   1/1     Running   0          5m59s
# kube-system   coredns-5c98db65d4-l5cnf                   1/1     Running   0          5m59s
# kube-system   etcd-master                                1/1     Running   0          5m13s
# kube-system   kube-addon-manager-master                  1/1     Running   0          6m17s
# kube-system   kube-apiserver-master                      1/1     Running   0          5m18s
# kube-system   kube-controller-manager-master             1/1     Running   0          4m52s
# kube-system   kube-proxy-95g9n                           1/1     Running   0          5m58s
# kube-system   kube-proxy-bghgg                           1/1     Running   0          27s
# kube-system   kube-proxy-hgcxb                           1/1     Running   0          57s
# kube-system   kube-scheduler-master                      1/1     Running   0          4m52s
# kube-system   kubernetes-dashboard-7d75c474bb-6b2sn      1/1     Running   0          3m32s

kubectl get nodes

# You will see response like this:
#
# NAME          STATUS   ROLES    AGE     VERSION
# master    Ready    master   6m47s   v1.15.3
# worker1   Ready    <none>   86s     v1.15.3
# worker2   Ready    <none>   56s     v1.15.3

kubectl get services --all-namespaces

# You will see response like this:
#
# NAMESPACE     NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
# default       kubernetes             ClusterIP   10.96.0.1       <none>        443/TCP                  21m
# kube-system   kube-dns               ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   21m
# kube-system   kubernetes-dashboard   ClusterIP   10.102.203.67   <none>        443/TCP                  19m
```

At this point you should have a fully-functional Kubernetes cluster on which you can run workloads.

## Run Dashboard

If you want to connect to the API Server from outside the cluster (e.g. your local workstation)
you must create a secure channel to your Kubernetes cluster using `kubectl`:

```shell script
kubectl proxy --accept-hosts='^*$'
```

And access Dashboard at:

[`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`](
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/).

To find out how to create sample user and log in follow
[Creating sample user](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md) guide.

## Clean-up

Execute the following command to remove the virtual machines created for the Kubernetes cluster:

```shell script
vagrant destroy -f
```

You can destroy individual machines by:

```shell script
vagrant destroy <VM NAME> -f
```

## License

This project is open source software licensed under the MIT Licence.
For more see LICENSE.txt file.
