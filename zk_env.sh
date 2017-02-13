#!/bin/bash -e

. $ZOO_HOME/common_functions.sh

function zk_local_cluster() {

  # Required envs for replicated mode
  export ZK_tickTime=${ZK_tickTime:-2000}
  export ZK_initLimit=${ZK_initLimit:-5}
  export ZK_syncLimit=${ZK_syncLimit:-2}

  ZOO_SERVER_PORT=${ZOO_SERVER_PORT:-2888}
  ZOO_ELECTION_PORT=${ZOO_ELECTION_PORT:-3888}

  for (( i=1; i<=$ZOO_REPLICAS; i++ )); do
    export ZK_server_$i="$NAME-$((i-1)).$DOMAIN:$ZOO_SERVER_PORT:$ZOO_ELECTION_PORT"
  done

}

HOST=`hostname -s`
DOMAIN=`hostname -d`

if [ $ZOO_REPLICAS -gt 1 ];then
  if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
    NAME=${BASH_REMATCH[1]}
    ORD=${BASH_REMATCH[2]}
    zk_local_cluster
    export ZOO_MY_ID=$((ORD+1))
  else
    echo "Unable to create local Zookeeper. Name of host doesn't match with pattern: (.*)-([0-9]+). Consider using PetSets or StatefulSets."
    exit 1
  fi
fi

export ZK_dataDir=${ZK_dataDir:-$ZOO_HOME/data}
export ZK_dataLogDir=${ZK_dataLogDir:-$ZOO_HOME/data-log}

export ZK_clientPort=${ZK_clientPort:-2181}


# Remove invalid options per version
if ! version_gt $ZOO_VERSION "3.4.5"; then
  unset ZK_maxClientCnxns
fi

if ! version_gt $ZOO_VERSION "3.3.6"; then
  unset ZK_autopurge_snapRetainCount
  unset ZK_autopurge_purgeInterval
fi

exec "$@"