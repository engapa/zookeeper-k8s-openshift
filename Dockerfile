FROM openjdk:11-jre-slim-buster

MAINTAINER Enrique Garcia <engapa@gmail.com>

ARG ZOO_HOME=/opt/zookeeper
ARG ZOO_USER=zookeeper
ARG ZOO_GROUP=zookeeper
ARG ZOO_VERSION="3.7.0"

ENV ZOO_HOME=$ZOO_HOME \
    ZOO_VERSION=$ZOO_VERSION \
    ZOO_REPLICAS=1 \
    ZOO_USER=$ZOO_USER \
    ZOO_GROUP=$ZOO_GROUP \
    ZOOCFGDIR=$ZOO_HOME/conf \
    PATH=$ZOO_HOME/bin:${PATH}

# Required packages
RUN apt update && \
    apt install -y tar gnupg openssl ca-certificates wget netcat sudo

# User and group
RUN groupadd -g 1001 $ZOO_GROUP \
    && useradd -d $ZOO_HOME -g $ZOO_GROUP -u 1001 -G sudo -m $ZOO_USER\
    && echo "${ZOO_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Download zookeeper distribution under ZOO_HOME directory
ADD zookeeper-download.sh /tmp/

RUN chmod a+x /tmp/zookeeper-download.sh \
    && /tmp/zookeeper-download.sh

# Add custom files.
ADD zkBootstrap.sh $ZOO_HOME/bin
ADD zookeeper-env.sh $ZOOCFGDIR

# Permissions
RUN chown -R $ZOO_USER:$ZOO_GROUP $ZOO_HOME && \
    chmod a+x $ZOO_HOME/bin/* && \
    chmod -R a+w $ZOO_HOME && \
    ln -s $ZOO_HOME/bin/zk_*.sh /usr/bin

USER $ZOO_USER

# Workdir for docker images is the same that ZOOBINDIR env variable for zookeeper process
WORKDIR $ZOO_HOME/bin/

EXPOSE ${ZK_clientPort:-2181} ${ZOO_SERVER_PORT:-2888} ${ZOO_ELECTION_PORT:-3888}

HEALTHCHECK --interval=10s --retries=10 CMD zkServer.sh status

CMD zkBootstrap.sh && zkServer.sh --config $ZOOCFGDIR start-foreground
