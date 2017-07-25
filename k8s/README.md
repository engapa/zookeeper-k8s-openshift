# Kubernetes resources

Here we have some examples of resources that may be deployed on your kubernetes environment.

Tests were done using version 1.6.0 of kubernetes.

## Launch a cluster

Adjust the contents of file `zk-persistent.yaml` file and type next command to create a zookeeper cluster:

```bash
$ kubectl create -f zk.yaml
```

## Use a helm chart

As you know Helm is a tool for managing kubernetes charts.

[Here](helm) you can find all details to install the zookeeper chart.

## Local environment

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

## Production environment

We recommend you to use resources with suffix **persistent** because of persistent storage.
This means that although pods are destroyed all data are safe under persistent volumes, and when pod are recreated the volumes are attached again.

The statefulset object has an "antiaffinity" pod scheduler policy so that pods will be allocated in separate nodes.
It's required the same number of nodes that the value of parameter `ZOO_REPLICAS`.

```bash
$ kubectl create -f zk-persistent.yaml
$ kubectl get all,pvc,statefulset -l zk-name=myzk
NAME       CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE
svc/myzk   None         <none>        2181/TCP,2888/TCP,3888/TCP   11m

NAME                DESIRED   CURRENT   AGE
statefulsets/myzk   3         3         11m

NAME        READY     STATUS    RESTARTS   AGE
po/myzk-0   1/1       Running   0          2m
po/myzk-1   1/1       Running   0          1m
po/myzk-2   1/1       Running   0          46s

NAME                    STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
pvc/datadir-myzk-0      Bound     pvc-a654d055-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datadir-myzk-1      Bound     pvc-a6601148-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datadir-myzk-2      Bound     pvc-a667fa41-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datalogdir-myzk-0   Bound     pvc-a657ff77-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datalogdir-myzk-1   Bound     pvc-a664407a-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datalogdir-myzk-2   Bound     pvc-a66b85f7-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m

NAME                DESIRED   CURRENT   AGE
statefulsets/myzk   3         3         11m
```


## Cleanup

This command removes all resources belong to zookeeper cluster

```sh
kubectl delete all,statefulset,pvc -l app=<NAME>
```

> **NAME**: the name of the cluster provided by you when create it