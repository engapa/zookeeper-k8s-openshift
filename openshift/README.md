# Zookeeper cluster

Zookeeper cluster deployment.

The resources found here are templates for Openshift catalog.

It isn't necessary to clone this repo, you can use the resources with the prefix "https://raw.githubusercontent.com/engapa/zookeeper-k8s-openshift/master/openshift/" in order to get remote sources directly.

## Building the image

This is an optional step, you can always use the [public images at dockerhub](https://hub.docker.com/r/engapa/zookeeper) which are automatically uploaded.

Anyway, if you prefer to build the image in your private Openshift registry just follow these instructions:

1 - Create an image builder and build the container image

```sh
$ oc create -f buildconfig.yaml
$ oc new-app zk-builder -p GITHUB_REF="v3.4.10" IMAGE_STREAM_VERSION="3.4.10"
```

Explore the command `oc new-build` to create a builder via shell command client.

2 - Check that image is ready to use

```sh
$ oc get is -l component=zk [-n project]
NAME        DOCKER REPO                           TAGS      UPDATED
zookeeper   172.30.1.1:5000/myproject/zookeeper   3.4.10    1 days ago
```

3 - If you want to use this local/private image for your pod containers then use the "DOCKER REPO" value as `SOURCE_IMAGE` parameter value, and use one of the "TAGS" values as `ZOO_VERSION` parameter value (e.g: 172.30.1.1:5000/myproject/zookeeper:3.4.10).

4 - Launch the builder again with another commit or whenever you want:

```sh
$ oc start-build zk-builder --commit=master
```

## Launch a cluster

Just type next command to create a zookeeper cluster by using statefulset on Openshift:

```bash
$ oc create -f zookeeper.yaml
$ oc new-app zk -p ZOO_REPLICAS=1 [-p SOURCE_IMAGE="172.30.1.1:5000/myproject/zookeeper:3.4.10"]
```

You may use the Openshift dashboard if you prefer to do that through the web interface.

## Local testing

We recommend to use "minishift" in order to get quickly a ready Openshift deployment or use the "oc cluster up" command of latest versions of "oc" client

Check out the Openshift version by typing:

```bash
$ minishift get-openshift-versions
$ minishift config get openshift-version
```

If no version is showed in last command this means that the latest stable version will be used.

```bash
$ minishift config set openshift-version <version>
$ minishift start
$ oc create -f zookeeper-local.yaml
$ oc new-app zk [-p parameter=value]
$ minishift console
```

## Cleanup

Remove components of the cluster:

```sh
$ oc delete all,statefulset -l app=<NAME>
```
where NAME is the parameter value provided on creation time.

Note that there are still some resources, the build config (for using images form your private registry) and the persistent volumes and claims (pv, pvc).
Be careful, don't delete the persistent volume claim if you want to use it again in the future and preserve the data, or change de default policy (default is DELETE).

```sh
$ oc delete pv,pvc,bc,is -l component=zk
```

Remove the templates:

```sh
$ oc delete templates zk-builder zk
```






