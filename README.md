# Zookeeper Docker Image
[![Build status](https://circleci.com/gh/engapa/zookeeper-k8s-openshift/tree/master.svg?style=svg "Build status")](https://circleci.com/gh/engapa/zookeeper-k8s-openshift/tree/master)
[![License status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fengapa%2Fzookeeper-k8s-openshift.svg?type=shield "License status")](https://app.fossa.io/projects/git%2Bgithub.com%2Fengapa%2Fzookeeper-k8s-openshift?ref=badge_shield)
[![Docker Pulls](https://img.shields.io/docker/pulls/engapa/zookeeper.svg)](https://hub.docker.com/r/engapa/zookeeper/)
[![Docker Layering](https://images.microbadger.com/badges/image/engapa/zookeeper.svg)](https://microbadger.com/images/engapa/zookeeper)
[![Docker image version](https://images.microbadger.com/badges/version/engapa/zookeeper.svg)](https://microbadger.com/images/engapa/zookeeper)
![OSS](https://badges.frapsoft.com/os/v1/open-source.svg?v=103 "We love OpenSource")

The aim of this project is provide optimised zookeeper docker images to run into 'statefulsets' on kubernetes.

These are the main scripts used to build/run the docker image/container:

* **zk_env.sh**: Export needed env variable for other scripts.
* **zk_download.sh**: is used to download the suitable release of zookeeper (version `ZOO_VERSION`).
* **zk_setup.sh**: Configure zookeeper dynamically, based on [utils-docker project](https://github.com/engapa/utils-docker).
* **zk_status.sh**: health checks.

## Build and push the docker image

Set env variables DOCKER_ORG (defaults to engapa), DOCKER_IMAGE (defaults to zookeeper) and ZOO_VERSION (the real zookeeper version that will be downloaded into the docker image)
to tag docker image as you wish and then build, test and push:

```bash
$ make docker-build docker-test docker-push
```

## Run a container

By default the container entrypoint is `./zk_env.sh` and the command directive is `zk_setup.sh && ./zkServer.sh start-foreground`.

Let's run a zookeeper container with default environment variables:

```bash
$ docker run -it --name zk engapa/zookeeper:${ZOO_VERSION}
```

## Setting up

Users may configure parameters in config files just adding environment variables with specific name patterns.

This table collects the patterns of variable names which will are written in the suitable file:

PREFIX     | FILE (${ZOO_HOME}/config) |         Example
-----------|-----------------------------|-----------------------------
ZK_        | zoo.cfg | ZK_maxClientCnxns=0 --> maxClientCnxns=0
LOG4J_     | log4j.properties |  LOG4J_zookeeper_root_logger=INFO, CONSOLE--> zookeeper.root.logger=INFO, CONSOLE
JAVA_ZK_   | java.env | JAVA_ZK_JVMFLAG="-Xmx1G -Xms1G" --> JVMFLAG="-Xmx1G -Xms1G"

So we can configure our zookeeper server by adding environments variables:

```bash
$ docker run -it -d --name zk -e "SETUP_DEBUG=true" -e "LOG4J_zookeeper_root_logger=DEBUG, CONSOLE" engapa/zookeeper:${ZOO_VERSION}
```

> NOTE: We've passed a SETUP_DEBUG environment variable with value 'true' to view the setup process of config files.
> . Show logs by command `docker logs ZK`

Also you may use `--env-file` option to load these variables from a file.

And, of course, you could provide your own properties files directly by option `-v` and don't use `zk_setup.sh` script.

## k8s

In [k8s directory](k8s) there are some resources for Kubernetes.

Thanks to kubernetes team for the [contrib](https://github.com/kubernetes/contrib/tree/master/statefulsets/zookeeper).

## Openshift

In [openshift directory](openshift) you can find some Openshift templates.

## License

[![License status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fengapa%2Fzookeeper-k8s-openshift.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fengapas%2Fzookeeper-k8s-openshift?ref=badge_large)

## Author

Enrique Garcia **engapa@gmail.com**
