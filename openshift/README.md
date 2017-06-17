# Zookeeper cluster

Zookeeper cluster deployment.

The resources found here are templates for Openshift catalog.

## Launch a cluster

Just type next command to create a zookeeper cluster by using statefulset on Openshift:

```bash
$ oc create -f zookeeper.yaml
$ oc new-app zk -p ZOO_REPLICAS=1
```

You may use the Openshift dashboard if you prefer to do that from a web interface.

## Local testing

We recommend to use "minishift" in order to get quickly a ready Openshift deployment or use the "oc cluster up" command of latest versions of "oc" client

Check out the Openshift version by typing:

```bash
$ minishift get-openshift-versions
$ minishift config get openshift-version
```

If no version is showed in last command this means that the latest stable version is being used.

```bash
$ minishift config set openshift-version <version>
$ minishift start
$ oc create -f zookeeper-local.yaml
$ oc new-app zk [-p parameter=value]
$ minishift console
```








