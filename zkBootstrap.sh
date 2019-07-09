#!/bin/bash -e

. $ZOO_HOME/common_functions.sh
. $ZOOCFGDIR/zookeeper-env.sh

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

if [[ $ZOO_REPLICAS -gt 1 ]];then
  if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
    NAME=${BASH_REMATCH[1]}
    ORD=${BASH_REMATCH[2]}
    zk_local_cluster
    export MYID=$((ORD+1))
  else
    echo "Unable to create local Zookeeper. Name of host doesn't match with pattern: (.*)-([0-9]+). Consider to use PetSets or StatefulSets."
    exit 1
  fi
fi

if [[ -f $ZOOCFGDIR/zoo_sample.cfg ]]; then
  mv $ZOOCFGDIR/zoo_sample.cfg $ZOOCFGDIR/zoo.cfg
else
  touch $ZOOCFGDIR/zoo.cfg
fi

# Dynamic setup from environment variables to files
for dir in $ZOOCFGDIR $ZK_dataDir $ZK_dataLogDir;do
  if [[ ! -d $dir ]]; then
    echo "Creating directory $dir ..."
    mkdir -p $dir
  else
    # Ensure that we can write on directories (possible persistent volumes)
    echo "Ensuring permission for directory $dir ..."
    sudo chown -R $ZOO_USER:$ZOO_GROUP $dir
  fi
done

DEBUG=${SETUP_DEBUG:-false}
LOWER=${SETUP_LOWER:-false}

# Zookeeper config
PREFIX=ZK_ DEST_FILE=${ZOOCFGDIR}/zoo.cfg env_vars_in_file

# Tools log4j
PREFIX=LOG4J_ DEST_FILE=${ZOOCFGDIR}/log4j.properties env_vars_in_file

# Java
PREFIX=JAVA_ZK_ DEST_FILE=${ZOOCFGDIR}/java.env env_vars_in_file

# The myid for each node
export MYID=${MYID:-1}

zkServer-initialize.sh --configfile $ZOOCFGDIR/zoo.cfg --myid $MYID --force