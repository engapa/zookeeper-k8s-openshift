#!/bin/bash -e

### Default properties

ZOO_HOME=${KAFKA_HOME:-/opt/zookeeper}

function zk_local_cluster() {

  # Required envs for replicated mode
  export ZK_tickTime=${ZK_tickTime:-2000}
  export ZK_initLimit=${ZK_initLimit:-5}
  export ZK_syncLimit=${ZK_syncLimit:-2}

  export ZK_server_port=${ZK_server_port:-2888}
  export ZK_election_port=${ZK_election_port:-3888}

  for (( i=1; i<=$KAFKA_REPLICAS; i++ )); do
    export ZK_server_$i="$NAME-$((i-1)).$DOMAIN:$ZK_server_port:$ZK_election_port"
  done

}

HOST=`hostname -s`
DOMAIN=`hostname -d`

if [ $ZOO_REPLICAS -gt 1 ];then
  if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
    NAME=${BASH_REMATCH[1]}
    ORD=${BASH_REMATCH[2]}
    zk_local_cluster
  else
    echo "Unable to create local Zookeeper. Name of host doesn't match with pattern: (.*)-([0-9]+). Consider using PetSets or StatefulSets."
    exit 1
  fi
fi

export ZK_dataDir=${ZK_dataDir:-$KAFKA_HOME/zookeeper/data}
export ZK_dataLogDir=${ZK_dataLogDir:-$KAFKA_HOME/zookeeper/data-log}
mkdir -p ${ZK_dataDir} ${ZK_dataLogDir}

export ZK_clientPort=${ZK_clientPort:-2181}

exec "$@"