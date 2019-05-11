FROM openjdk:8-jre-alpine

MAINTAINER Enrique Garcia <engapa@gmail.com>

ARG ZOO_HOME=/opt/zookeeper
ARG ZOO_USER=zookeeper
ARG ZOO_GROUP=zookeeper
ARG ZOO_VERSION="3.4.14"

ENV ZOO_HOME=$ZOO_HOME \
    ZOO_VERSION=$ZOO_VERSION \
    ZOO_CONF_DIR=$ZOO_HOME/conf \
    ZOO_REPLICAS=1 \
    ZOO_USER=$ZOO_USER \
    ZOO_GROUP=$ZOO_GROUP

# Required packages
RUN set -ex; \
    apk add --update --no-cache \
      bash tar wget curl gnupg openssl ca-certificates sudo

# Download zookeeper distribution under ZOO_HOME directory
ADD zk_download.sh /tmp/

RUN set -ex; \
    mkdir -p $ZOO_HOME; \
    chmod a+x /tmp/zk_download.sh;

RUN /tmp/zk_download.sh

RUN set -ex; \
    rm -rf /tmp/zk_download.sh; \
    apk del wget gnupg

# Add custom scripts and configure user
ADD zk_env.sh zk_setup.sh zk_status.sh $ZOO_HOME/bin/

RUN set -ex; \
    addgroup -S -g 1001 $ZOO_GROUP && \
    adduser -h $ZOO_HOME -g "zookeeper" -u 1001 -D -S -G $ZOO_GROUP $ZOO_USER&& \
    chown -R $ZOO_USER:$ZOO_GROUP $ZOO_HOME && \
    chmod a+x $ZOO_HOME/bin/* && \
    chmod -R a+w $ZOO_HOME && \
    ln -s $ZOO_HOME/bin/zk_*.sh /usr/bin && \
    echo "${ZOO_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $ZOO_USER
WORKDIR $ZOO_HOME/bin/

EXPOSE ${ZK_clientPort:-2181} ${ZOO_SERVER_PORT:-2888} ${ZOO_ELECTION_PORT:-3888}

HEALTHCHECK --interval=10s --retries=10 CMD "./zk_status.sh"

ENTRYPOINT ["./zk_env.sh"]

CMD zk_setup.sh && ./zkServer.sh start-foreground
