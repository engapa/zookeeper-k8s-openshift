FROM openjdk:8-jre-alpine

MAINTAINER Enrique Garcia <engapa@gmail.com>

ARG ZOO_HOME=/opt/zookeeper
ARG ZOO_USER=zookeeper
ARG ZOO_GROUP=zookeeper
ARG ZOO_VERSION="3.6.0"

ENV ZOO_HOME=$ZOO_HOME \
    ZOO_VERSION=$ZOO_VERSION \
    ZOO_REPLICAS=1 \
    ZOO_USER=$ZOO_USER \
    ZOO_GROUP=$ZOO_GROUP \
    ZOOCFGDIR=$ZOO_HOME/conf \
    PATH=$ZOO_HOME/bin:${PATH}

# Required packages
RUN apk add --update --no-cache \
      bash tar wget curl gnupg openssl ca-certificates sudo

# Download zookeeper distribution under ZOO_HOME directory
ADD zookeeper-download.sh /tmp/

RUN mkdir -p $ZOO_HOME && \
    chmod a+x /tmp/zookeeper-download.sh

RUN /tmp/zookeeper-download.sh

RUN rm -rf /tmp/zookeeper-download.sh && \
    apk del wget gnupg

# Add custom files.
ADD zkBootstrap.sh $ZOO_HOME/bin
ADD zookeeper-env.sh $ZOOCFGDIR

RUN addgroup -S -g 1001 $ZOO_GROUP && \
    adduser -h $ZOO_HOME -g "zookeeper" -u 1001 -D -S -G $ZOO_GROUP $ZOO_USER&& \
    chown -R $ZOO_USER:$ZOO_GROUP $ZOO_HOME && \
    chmod a+x $ZOO_HOME/bin/* && \
    chmod -R a+w $ZOO_HOME && \
    ln -s $ZOO_HOME/bin/zk_*.sh /usr/bin && \
    echo "${ZOO_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $ZOO_USER

# Workdir for docker images is the same that ZOOBINDIR env variable for zookeeper process
WORKDIR $ZOO_HOME/bin/

EXPOSE ${ZK_clientPort:-2181} ${ZOO_SERVER_PORT:-2888} ${ZOO_ELECTION_PORT:-3888}

HEALTHCHECK --interval=10s --retries=10 CMD zkServer.sh status

CMD zkBootstrap.sh && zkServer.sh --config $ZOOCFGDIR start-foreground
