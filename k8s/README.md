# Kubernetes resources

Here we have some examples of resources that may be deployed on your kubernetes environment.

## Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (kubernetes client, 1.10 \>=)
- Kubernetes (1.10)

## Launch a cluster

Adjust the contents of file `zk.yaml` file and type next command to create a zookeeper cluster:

```bash
$ kubectl create -f zk.yaml
```

## Use a helm chart

As you know Helm is a tool for managing kubernetes charts.

[Here](helm) you can find all details to install the zookeeper chart.

## Local environment

We recommend to use "minikube" in order to get quickly a ready kubernetes cluster.

Check out the kubernetes version by typing:

```bash
$ minikube get-k8s-versions
$ minikube config get kuberntes-version
```

If no version is showed in last command this means that the latest stable version is being used.

```bash
$ minikube config set kuberntes-version <version>
$ minikube start
$ kubectl create -f zookeeper-local.yaml
$ minikube dashboard
```

## Production environment

We recommend you to use resources with suffix **persistent** because of persistent storage.
This means that although pods are destroyed all data are safe under persistent volumes, and when pod are recreated the volumes are attached again.

The statefulset object has an "antiaffinity" pod scheduler policy so that pods will be allocated in separate nodes.
It's required the same number of nodes that the value of parameter `ZOO_REPLICAS`.

```bash
$ kubectl create -f zk[-persistent].yaml
$ kubectl get all,pvc,statefulset -l zk-name=myzk
```

## Cleanup

This command removes all resources belong to zookeeper cluster

```bash
kubectl delete all,statefulset,pvc -l app=<NAME>
```

> **NAME**: the name of the cluster provided by you when create it