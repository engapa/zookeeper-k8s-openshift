# Apache Zookeeper Helm Chart

## Pre Requisites:

* Kubernetes 1.10

* More than 1 node (if replicas is upper than 1) because of an antiaffinity scheduler policy

### Installing the Chart

To install the chart with the release name `zookeeper-<release>` in the default
namespace:

```bash
$ helm repo add engapa http://storage.googleapis.com/kubernetes-charts-incubator
$ helm install --name zookeeper-3.4.13 engapa/zookeeper
```

If you're using a dedicated namespace (recommended) then make sure the namespace
exists:

```bash
$ kubectl create ns zookeeper
$ helm install --name zookeeper-3.4.13 --set global.namespace=zookeeper engapa/zookeeper
```

The chart can be customized using the
following configurable parameters:

| Parameter               | Description                         | Default                                                    |
| ----------------------- | ----------------------------------- | ---------------------------------------------------------- |
| `Name`                  | Zookeeper resource names            | `zk`                                                       |
| `Image`                 | Zookeeper container image name      | `engapa/zookeeper`                                            |
| `ImageTag`              | Zookeeper container image tag       | `3.4.13`                                                 |
| `ImagePullPolicy`       | Zookeeper container pull policy     | `IfNotPresent`                                                   |
| `Replicas`              | Zookeeper replicas                  | `3`                                                        |
| `Component`             | Zookeeper k8s selector key          | `zk`                                                    |
| `Cpu`                   | Zookeeper container requested cpu   | `500m`                                                     |
| `Memory`                | Zookeeper container requested memory| `512Mi`                                                    |
| `MaxCpu`                | Zookeeper container cpu limit       | `2`                                                     |
| `MaxMemory`             | Zookeeper container memory limit    | `1Gi`                                                     |

Specify parameters using `--set key=value[,key=value]` argument to `helm install`

Alternatively a YAML file that specifies the values for the parameters can be provided like this:

```bash
$ helm install --name zookeeper-3.4.13 -f values.yaml engapa/zookeeper
```

