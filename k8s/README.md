# Kubernetes resources

Here we have some examples of resources that may be deployed on your kubernetes environment.

Tests were done using version 1.6.0 of kubernetes.


## Launch a cluster

Just type next command to create a zookeeper cluster:

```bash
$ kubectl create -f zookeeper.yaml
```

You may use the Openshift dashboard if you prefer to do that from a web interface.

## Local testing

We recommend to use "minikube" in order to get quickly a ready kubernetes deployment.

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

## Cleanup

This command removes all resources belong to zookeeper cluster

```sh
kubectl delete all,statefulset,pvc -l app=<NAME>
```

> **NAME**: the name of the cluster provided by you when create it