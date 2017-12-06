[![Build Status](https://travis-ci.org/engapa/zookeeper-k8s-openshift.svg)](https://travis-ci.org/engapa/zookeeper-k8s-openshift)
[![Docker Pulls](https://img.shields.io/docker/pulls/engapa/zookeeper.svg)](https://hub.docker.com/r/engapa/zookeeper/)
[![Docker Stars](https://img.shields.io/docker/stars/engapa/zookeeper.svg)](https://hub.docker.com/r/engapa/zookeeper/)
[![Docker Layering](https://images.microbadger.com/badges/image/engapa/zookeeper.svg)](https://microbadger.com/images/engapa/zookeeper)
[![Docker image version](https://images.microbadger.com/badges/version/engapa/zookeeper.svg)](https://microbadger.com/images/engapa/zookeeper)
# Zookeeper Docker Image

The aim of this project is provide optimised zookeeper docker images to run into 'statefulsets' on kubernetes.

These main scripts are used to build/run the image/container:

* zk_env.sh: Export needed env variable for other scripts.
* zk_download.sh: is used to download the suitable release of zookeeper (version `ZOO_VERSION`).
* zk_setup.sh: Configure zookeeper dynamically, based on [utils-docker project](https://github.com/engapa/utils-docker).
* zk_status.sh: health checks.

# Building the docker image

```bash
$ export ZOO_HOME="/opt/zookeeper"
$ export ZOO_VERSION="3.4.11"
$ docker build --build-arg ZOO_VERSION=$ZOO_VERSION --build-arg ZOO_HOME=$ZOO_HOME \
-t engapa/zookeeper:${ZOO_VERSION} .
```

> NOTE: `build-arg` options and export directives are optional.

# Run a container

By default the container entrypoint is `./zk_env.sh` and the cmd directive is `zk_setup.sh && ./zkServer.sh start-foreground`.

Let's run a zookeeper container with default environment variables:

```bash
$ docker run -it engapa/zookeeper:${ZOO_VERSION}
```

## Setting up

Users can configure parameters in config files just adding environment variables with specific name patterns.

This table collects the patterns of variable names which will are written in the suitable file:

PREFIX     | FILE (${ZOO_HOME}/config) |         Example
-----------|-----------------------------|-----------------------------
ZK_        | zoo.cfg | ZK_maxClientCnxns=0 --> maxClientCnxns=0
LOG4J_     | log4j.properties |  LOG4J_log4j_rootLogger=INFO, stdout--> log4j.rootLogger=INFO, stdout
JAVA_ZK_   | java.env | JAVA_ZK_JVMFLAG="-Xmx1G -Xms1G" --> JVMFLAG="-Xmx1G -Xms1G"

So we can configure our zookeeper server by adding environments variables:

```bash
$ docker run -it -d -e "SETUP_DEBUG=true" -e "LOG4J_log4j_rootLogger=DEBUG, stdout"
```

> NOTE: We've passed a SETUP_DEBUG environment variable with value 'true' to view the setup process of config files.

Also you may use `--env-file` option to load these variables from a file.

And, of course, you could provide your own properties files directly by option `-v` and don't use `zk_setup.sh` script.

# k8s

In [k8s directory](k8s) there are some resources for Kubernetes.

Thanks to kubernetes team for the [contrib](https://github.com/kubernetes/contrib/tree/master/statefulsets/zookeeper).

# Openshift

In [openshift directory](openshift) you can find some Openshift templates.

# Author

Enrique Garcia **engapa@gmail.com**
