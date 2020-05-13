# Zookeeper cluster

Zookeeper cluster deployment.

The resources found here are templates for Openshift catalog.

It isn't necessary to clone this repo, you can use directly resource URLs.

## Requirements

- [oc](https://github.com/openshift/origin/releases) (v3.11)
- [minishift](https://github.com/minishift/minishift) (v1.33.0)

### DEV environment

We'll use only opensource, that is 'openshift origin'.

[Minishift](https://github.com/minishift/minishift) is the simplest way to get a local Openshift installation on our workstation.
After install the command client check everything is alright to continue:

```bash
$ minishift version
minishift v1.33.0+ba29431
$ minishift start [options]
...
$ minishift openshift version
openshift v3.11.0+57f8760-31
```
>NOTE: minishift has configured the oc client correctly to connect to local Openshift cluster properly.

With `oc` command client is possible get up a cluster as well, take a look at: https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md

Check that our cluster is ready:

```bash
$ oc version
oc v3.11.0+0cbc58b
kubernetes v1.17.0+d4cacc0
features: Basic-Auth

Server https://192.168.2.32:8443
kubernetes v1.17.0+d4cacc0
```

You may use the Openshift dashboard (`minishift console`) if you prefer to do those steps through the web interface,
in other case use `oc` command client:

```bash
oc login -u system:admin
```

### PROD environment

To connect to external cluster we need to know the URL to login with your credentials.

For production environments we'll use zookeeper deployments with persistence (zk-persistent.yaml).

We recommend you to use **zk-persistent.yaml**.
This means that although pods are destroyed all data are safe under persistent volumes, and when pods are recreated the volumes will be attached again.

The statefulset object has an "antiaffinity" pod scheduler policy so pods will be allocated on separated nodes (uncomment those lines at `zk-persistent.yaml` file to activate it).
It's required the same number of nodes that the value of parameter `ZOO_REPLICAS`.

## Building the image

This is a recommended step, although you can always use the [public images at dockerhub](https://hub.docker.com/r/engapa/zookeeper) which are automatically uploaded with CI of this project.

To build local docker images of zookeeper in your private Openshift registry just follow these instructions:

1 - Create an image builder and build the container image locally

```bash
$ oc create -f buildconfig.yaml
$ oc new-app zk-builder -p GITHUB_REF="v3.6.1" -p IMAGE_STREAM_VERSION="v3.6.1"
```

If you want to get an image from another git commit:

```bash
$ oc start-build zk-builder --commit=master
```

Or build a local docker image from source directly:
```bash
$ ./main build_local_image
```

**NOTE**: If you want to use this local/private image from containers on other projects then use the "\<project\>/NAME" value as `SOURCE_IMAGE` parameter value, and use one value of "TAGS" as `ZOO_VERSION` parameter value (e.g: test/zookeeper:3.6.1).

## Deploying zookeeper cluster

Just type next command to create a zookeeper cluster by using a statefulset on Openshift:

```bash
$ oc create -f zk[-persistent].yaml
$ oc new-app zk -p ZOO_REPLICAS=1 -p SOURCE_IMAGE="172.30.1.1:5000/myproject/zookeeper" -p ZOO_VERSION="3.6.1"
```
> NOTE: select zk.yaml or zk-persistence.yaml, and set parameter values

For example, if you deployed a persistent zookeeper with ZOO_REPLICAS=1:

```bash
$ oc get all,pvc,pv -l component=zk
NAME                  READY     STATUS    RESTARTS   AGE
pod/zk-persistent-0   1/1       Running   0          53s

NAME                    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE
service/zk-persistent   ClusterIP   None         <none>        2181/TCP,2888/TCP,3888/TCP   53s

NAME                             DESIRED   CURRENT   AGE
statefulset.apps/zk-persistent   1         1         53s

NAME                                               STATUS    VOLUME                         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/datadir-zk-persistent-0      Bound     zk-persistent-datalog-disk-1   1Gi        RWO                           53s
persistentvolumeclaim/datalogdir-zk-persistent-0   Bound     zk-persistent-data-disk-1      1Gi        RWO                           53s

NAME                                            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                                  STORAGECLASS   REASON    AGE
persistentvolume/zk-persistent-data-disk-1      1Gi        RWO            Retain           Bound     myproject/datalogdir-zk-persistent-0                            54s
persistentvolume/zk-persistent-datalog-disk-1   1Gi        RWO            Retain           Bound     myproject/datadir-zk-persistent-0                               53s
```

You may use the `main.sh` script on this directory:
```bash
$ ./main test <replicas-number>
```
or 
```bash
$ ./main test-persistent <replicas-number>
```
> NOTE: Where <replicas-number> is the number or replicas you want, by default 1.

## Cleaning up

To remove all resources related to the zookeeper cluster deployment launch this command:

```bash
$ oc delete all -l component=zk [-n <namespace>|--all-namespaces]
```

And finally, you want to remove the template as well:

```bash
$ oc delete template zk-builder [-n <namespace>|--all-namespaces]
$ oc delete template zk[-persistent] [-n <namespace>|--all-namespaces]
```

You may use the `main.sh` script on this directory:
```bash
$ ./main clean-resources
```