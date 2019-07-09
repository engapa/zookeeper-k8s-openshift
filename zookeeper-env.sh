#!/bin/bash -e

export ZK_dataDir=${ZK_dataDir:-$ZOO_HOME/data}
export ZK_dataLogDir=${ZK_dataLogDir:-$ZOO_HOME/data-log}
export ZK_clientPort=${ZK_clientPort:-2181}

export ZOOPIDFILE=$ZK_dataDir/myid
export ZOOCFG=$ZOOCFGDIR/zoo.cfg
