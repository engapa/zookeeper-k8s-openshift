#!/bin/bash -e

. $ZOO_HOME/common_functions.sh

whoami
id
ls -lisah $ZOO_HOME

for dir in $ZOO_CONF_DIR $ZK_dataDir $ZK_dataLogDir;do
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

if [[ -f $ZOO_CONF_DIR/zoo_sample.cfg ]]; then
  mv $ZOO_CONF_DIR/zoo_sample.cfg $ZOO_CONF_DIR/zoo.cfg
fi

# Zookeeper config
PREFIX=ZK_ DEST_FILE=${ZOO_CONF_DIR}/zoo.cfg env_vars_in_file

# Tools log4j
PREFIX=LOG4J_ DEST_FILE=${ZOO_CONF_DIR}/log4j.properties env_vars_in_file

# Java
PREFIX=JAVA_ZK_ DEST_FILE=${ZOO_CONF_DIR}/java.env env_vars_in_file

# Write myid only if it doesn't exist
if [[ ! -f "$ZK_dataDir/myid" ]]; then
  echo "${ZOO_MY_ID:-1}" > "$ZK_dataDir/myid"
fi
