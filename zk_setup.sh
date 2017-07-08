#!/bin/bash -e

. $ZOO_HOME/common_functions.sh

ZK_dataDir=${ZK_dataDir:-$ZOO_HOME/data}

mkdir -p $ZOO_CONF_DIR $ZK_dataDir

if [ ! -z $ZK_dataLogDir ]; then
  mkdir -p $ZK_dataLogDir
fi

DEBUG=${SETUP_DEBUG:-false}
LOWER=${SETUP_LOWER:-false}

if [ -f $ZOO_CONF_DIR/zoo_sample.cfg ]; then
  mv $ZOO_CONF_DIR/zoo_sample.cfg $ZOO_CONF_DIR/zoo.cfg
fi

# Zookeeper config
PREFIX=ZK_ DEST_FILE=${ZOO_CONF_DIR}/zoo.cfg env_vars_in_file

# Tools log4j
PREFIX=LOG4J_ DEST_FILE=${ZOO_CONF_DIR}/log4j.properties env_vars_in_file

# Java
PREFIX=JAVA_ZK_ DEST_FILE=${ZOO_CONF_DIR}/java.env env_vars_in_file

# Write myid only if it doesn't exist
if [ ! -f "$ZK_dataDir/myid" ]; then
  echo "${ZOO_MY_ID:-1}" > "$ZK_dataDir/myid"
fi
