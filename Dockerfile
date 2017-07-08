FROM java:8-jre-alpine

MAINTAINER Enrique Garcia <engapa@gmail.com>

ARG ZOO_HOME=/opt/zookeeper
ARG ZOO_USER=zookeeper
ARG ZOO_GROUP=zookeeper
ARG ZOO_VERSION="3.4.10"

ENV ZOO_HOME=$ZOO_HOME \
    ZOO_VERSION=$ZOO_VERSION \
    ZOO_CONF_DIR=$ZOO_HOME/conf \
    ZOO_REPLICAS=1

# Required packages
RUN set -ex; \
    apk add --update --no-cache \
      bash tar wget curl gnupg openssl ca-certificates

# Download zookeeper distribution under ZOO_HOME directory
ADD zk_download.sh /tmp/

RUN set -ex; \
    mkdir -p $ZOO_HOME; \
    chmod a+x /tmp/zk_download.sh; \
    /tmp/zk_download.sh; \
    rm -rf /tmp/zk_download.sh; \
    apk del wget gnupg

# Add custom scripts and configure user
ADD zk_env.sh zk_setup.sh zk_status.sh $ZOO_HOME/bin/

RUN set -ex; \
    chmod a+x $ZOO_HOME/bin/zk_*.sh; \
    addgroup $ZOO_GROUP; \
    addgroup sudo; \
    adduser -h $ZOO_HOME -g "Zookeeper user" -s /sbin/nologin -D -G $ZOO_GROUP -G sudo $ZOO_USER; \
    chown -R $ZOO_USER:$ZOO_GROUP $ZOO_HOME; \
    ln -s $ZOO_HOME/bin/zk_*.sh /usr/bin

USER $ZOO_USER
WORKDIR $ZOO_HOME/bin/

EXPOSE ${ZK_clientPort:-2181} ${ZOO_SERVER_PORT:-2888} ${ZOO_ELECTION_PORT:-3888}

ENTRYPOINT ["./zk_env.sh"]

CMD zk_setup.sh && ./zkServer.sh start-foreground
