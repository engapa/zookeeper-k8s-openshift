# Kubernetes resources

Here we have some examples of resources that may be deployed on your kubernetes environment.

## Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- Kubernetes

## Launch a cluster

Adjust the contents of file `zk.yaml` file and type next command to create a zookeeper cluster:

If you have a kubernetes cluster ready, then:

```bash
$ kubectl create -f zk[-persistent].yaml
```
>NOTE: choose file zk.yaml or zk-persistent.yaml.

## Local environment

We recommend to use "minikube" in order to get quickly a ready kubernetes cluster.

The script "main.sh" may help you to do that on your local workstation (checked on Debian/Ubuntu distributions):

```bash
$ ./main.sh 
```

Install kubectl:
```bash
$ ./main.sh kubectl-install
```

Install and run minikube:
```bash
$ ./main.sh minikube-install
$ ./main.sh minikube-run
```

Deploy zookeeper cluster:
```bash
$ ./main.sh test
```

Deploy zookeeper cluster with persistent storage:
```bash
$ ./main.sh test-persistent
```

Clean all resources and delete minikube cluster:
```bash
$ ./main.sh clean-all
$ ./main.sh minikube-delete
```

## Production environment

We recommend you to use resources with suffix **persistent** because of persistent storage.
This means that although pods are destroyed all data are safe under persistent volumes, and when pod are recreated the volumes are attached again.

The statefulset object has an "antiaffinity" pod scheduler policy so those pods will be allocated in separate nodes.
It's required the same number of nodes that the value of parameter `ZOO_REPLICAS`.

```bash
$ kubectl create -f zk-persistent.yaml
$ kubectl get all,pv,pvc -l component=zk
```

## Cleanup

This command removes all resources belong to zookeeper cluster

```bash
kubectl delete -f zk[-persistent].yaml
```
