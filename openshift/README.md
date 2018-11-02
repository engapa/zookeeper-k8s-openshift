# Zookeeper cluster

Zookeeper cluster deployment.

The resources found here are templates for Openshift catalog.

It isn't necessary to clone this repo, you can use directly resource URLs.

## Requirements

- [oc](https://github.com/openshift/origin/releases) (openshift client, 3.10 \>=)
- Openshift cluster (3.10 \>=)

### DEV environment

We'll use only opensource, that is 'openshift origin'.

[Minishift](https://github.com/minishift/minishift) is the simplest way to get a local Openshift installation on our workstation.
After install the command client check everything is alright to continue:

```bash
[$ minishift update]
$ minishift version
minishift v1.26.1+1e20f27
$ minishift start [options]
...
Version: v3.11.0
...
$ minishift openshift version
openshift v3.11.0+57f8760-31
```
>NOTE: minishift has configured the oc client correctly to connect to local Openshift cluster properly.

With `oc` tools is possible get up a cluster as well, take a look at: https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md

Supposing we have our openshift cluster ready:

```bash
$ oc version
oc v3.11.0+0cbc58b
kubernetes v1.11.0+d4cacc0
features: Basic-Auth

Server https://192.168.2.32:8443
kubernetes v1.11.0+d4cacc0
```

Login with admin user and provide a password:

```bash
$ oc login -u admin -p xxxxx
```

Create a new project:

```bash
$ oc new-project test 
```

You may use the Openshift dashboard (`minishift console`) if you prefer to do those steps through the web interface.

> TRICK: Login as cluster admin: `oc login -u system:admin -n default`,
 change permissions of default scc `oc edit scc restricted` and change runAsUser.type value to RunAsAny.
 

For local environment we'll use a non persistent deployments (zk.yaml)

### PROD environment

To connect to external cluster we need to know the URL to login with your credentials.

For production environments we'll use zookeeper deployments with persistence (zk-persistent.yaml).

We recommend you to use **zk-persistent.yaml**.
This means that although pods are destroyed all data are safe under persistent volumes, and when pod are recreated the volumes will be attached again.

The statefulset object has an "antiaffinity" pod scheduler policy so pods will be allocated in separate nodes.
It's required the same number of nodes that the value of parameter `ZOO_REPLICAS`.

## Building the image

This is a recommended step, although you can always use the [public images at dockerhub](https://hub.docker.com/r/engapa/zookeeper) which are automatically uploaded with CI of this project.

To build and save a docker image of zookeeper in your private Openshift registry just follow these instructions:

1 - Create an image builder and build the container image

```bash
$ oc create -f buildconfig.yaml
$ oc new-app zk-builder -p GITHUB_REF="v3.4.13" -p IMAGE_STREAM_VERSION="3.4.13"
```

If you want to get an image from another git commit:

```bash
$ oc start-build zk-builder --commit=master
```

2 - Check that image is ready:

```bash
$ oc get is -l component=zk [-n project]
NAME        DOCKER REPO                           TAGS      UPDATED
zookeeper   172.30.1.1:5000/test/zookeeper       3.4.13    1 days ago
```

**NOTE**: If you want to use this local/private image from containers on other projects then use the "\<project\>/NAME" value as `SOURCE_IMAGE` parameter value, and use one value of "TAGS" as `ZOO_VERSION` parameter value (e.g: test/zookeeper:3.4.13).

## Deploy zookeeper cluster

Just type next command to create a zookeeper cluster by using statefulset resources on Openshift:

```bash
$ oc create -f zk[-persistent].yaml
$ oc new-app zk -p ZOO_REPLICAS=1 -p SOURCE_IMAGE="172.30.1.1:5000/test/zookeeper" -p ZOO_VERSION="3.4.13"
```
> NOTE: select zk.yaml or zk-persistence.yaml, and set parameter values

For example, if you deployed a persistence zookeeper with ZOO_REPLICAS=1:

```bash
$ oc get all,pvc,statefulset -l zk-name=zk
NAME       CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE
svc/zk     None         <none>        2181/TCP,2888/TCP,3888/TCP   11m

NAME                DESIRED   CURRENT   AGE
statefulsets/zk     3         3         11m

NAME        READY     STATUS    RESTARTS   AGE
po/zk-0     1/1       Running   0          2m
po/zk-1     1/1       Running   0          1m
po/zk-2     1/1       Running   0          46s

NAME                    STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
pvc/datadir-zk-0        Bound     pvc-a654d055-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datadir-zk-1        Bound     pvc-a6601148-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datadir-zk-2        Bound     pvc-a667fa41-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datalogdir-zk-0     Bound     pvc-a657ff77-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datalogdir-zk-1     Bound     pvc-a664407a-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m
pvc/datalogdir-zk-2     Bound     pvc-a66b85f7-6dfa-11e7-abe1-42010a840002   1Gi        RWO           11m

NAME                DESIRED   CURRENT   AGE
statefulsets/zk      3         3         11m
```

## Clean up

To remove all resources related to the zookeeper cluster deployment launch this command:

```bash
$ oc delete all,statefulset[,pvc] -l zk-name=<name> [-n <namespace>|--all-namespaces]
```
where '<name>' is the value of param NAME (default value zk). Note that pvc resources are marked as optional in the command,
it's up to you preserver or not the persistent volumes (by default when a pvc is deleted the persistent volume will be deleted as well).
Type the namespace option if you are in a different namespace that resources are, and indicate --all-namespaces option if all namespaces should be considered.

It's possible delete all resources created by using the template:
with cluster created by template name:

```bash
$ oc delete all,statefulset[,pvc] -l template=zk[-persistent] [-n <namespace>] [--all-namespaces]
```

Also someone can remove all resources of type zk, belong to all clusters and templates:

```bash
$ oc delete all,statefulset[,pvc] -l component=zk [-n <namespace>] [--all-namespaces]
```

And finally if you even want to remove the template:

```bash
$ oc delete template zk-builder [-n <namespace>] [--all-namespaces]
$ oc delete template zk[-persistent] [-n <namespace>] [--all-namespaces]
```
