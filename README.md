[![CircleCI](https://circleci.com/gh/engapa/zookeeper-docker/tree/master.svg?style=svg)](https://circleci.com/gh/engapa/zookeeper-docker/tree/master)
[![Docker Pulls](https://img.shields.io/docker/pulls/engapa/zookeeper.svg)](https://hub.docker.com/r/engapa/zookeeper/)
[![Docker Stars](https://img.shields.io/docker/stars/engapa/zookeeper.svg)](https://hub.docker.com/r/engapa/zookeeper/)
[![Docker Layering](https://images.microbadger.com/badges/image/engapa/zookeeper.svg)](https://microbadger.com/images/engapa/zookeeper)
# Zookeeper Docker Image

The aim of this project is create/use zookeeper docker images.

# Build an image

```bash
$ export ZOO_HOME="/opt/zookeeper"
$ export ZOO_VERSION="3.4.10"
$ docker build --build-arg ZOO_VERSION=$ZOO_VERSION --build-arg ZOO_HOME=$ZOO_HOME \
-t engapa/zookeeper:${ZOO_VERSION} .
```

The **zk_download.sh** script is used to download the suitable release.
The built docker image will contain a zookeeper distribution (${ZOO_VERSION}) under the directory $ZOO_HOME.

Besides, we've added two scripts :

* zk_env.sh : Export needed env variable for setup script.
* zk_setup.sh : Configure zookeeper dynamically, based on [utils-docker project](https://github.com/engapa/utils-docker)

# Run a container

By default the container entrypoint is `./zk_env.sh` and the cmd directive is `zk_setup.sh && ./zkServer.sh start-foreground`.

Let's run a zookeeper container :

```bash
$ docker run -it -e "SETUP_DEBUG=true" engapa/zookeeper:${ZOO_VERSION}
```

>NOTE: We've pass a SETUP_DEBUG environment variable to view the setup process of config files.

## Setting up

Users can pass parameters to config files just adding environment variables with specific name patterns.

This table collects the patterns of variable names which will are written in each file:

PREFIX     | FILE (${ZOO_HOME}/config) |         Example
-----------|-----------------------------|-----------------------------
ZK_        | zoo.cfg | ZK_maxClientCnxns=0 --> maxClientCnxns=0
LOG4J_     | log4j.properties |  LOG4J_log4j_rootLogger=INFO, stdout--> log4j.rootLogger=INFO, stdout
JAVA_ZK_   | java.env | JAVA_ZK_JVMFLAG="-Xmx1G -Xms1G" --> JVMFLAG="-Xmx1G -Xms1G"

So we can configure our zookeeper server in docker run time:

```bash
$ docker run -it -d -e "LOG4J_log4j_rootLogger=DEBUG, stdout"
```

Also you may use `--env-file` option to load these variables from a file.

And, of course, you could provide your own properties files directly by option `-v` and don't use zk_setup script.

# k8s

In [k8s directory](k8s) directory there are some resources for Kubernetes.

Thanks to kubernetes team for the [contrib](https://github.com/kubernetes/contrib/tree/master/statefulsets/zookeeper).

# Openshift

In [openshift](openshift) directory we have a couple of templates to install within Openshift.

# Author

Enrique Garcia **engapa@gmail.com**