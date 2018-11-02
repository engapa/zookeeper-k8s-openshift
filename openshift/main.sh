#!/usr/bin/env bash

set -e

ZK_VERSION=${ZK_VERSION:-"3.4.13"}
ZK_IMAGE="engapa/zookeeper:${ZK_VERSION}"

MINISHIFT_VERSION=${MINISHIFT_VERSION:-"v1.26.1"}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function oc-install()
{
  # Download oc
  curl -LO https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
  tar -xvzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
  mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc ./oc
  rm -rf openshift-origin-client-tools*
  chmod a+x oc
  sudo mv oc /usr/local/bin/oc
}

function oc-cluster-run()
{

  # Add internal insecure registry
  sudo sed -i 's#^ExecStart=.*#ExecStart=/usr/bin/dockerd --insecure-registry='172.30.0.0/16' -H fd://#' /lib/systemd/system/docker.service
  sudo systemctl daemon-reload
  sudo systemctl restart docker

  # Run openshift cluster
  oc cluster up --enable=[*]

  # Waiting for cluster
  for i in {1..150}; do # timeout for 5 minutes
     oc cluster status &> /dev/null
     if [ $? -ne 1 ]; then
        break
    fi
    sleep 2
  done

  oc create -f $DIR/zk.yaml
  oc create -f $DIR/zk-persistent.yaml

}

# $1 : Number of replicas
function check()
{

  SLEEP_TIME=10
  MAX_ATTEMPTS=10
  ATTEMPTS=0
  until [ "$(oc get statefulset -l zk-name=zk -o jsonpath='{.items[?(@.kind=="StatefulSet")].status.currentReplicas}' 2>&1)" == "$2" ]; do
    sleep $SLEEP_TIME
    ATTEMPTS=`expr $ATTEMPTS + 1`
    if [[ $ATTEMPTS -gt $MAX_ATTEMPTS ]]; then
      echo "ERROR: Max number of attempts was reached (${MAX_ATTEMPTS})"
      exit 1
    fi
   echo "Retry [${ATTEMPTS}] ... "
  done
}

function test()
{
  # Given
  # When
  oc new-app zk -p ZOO_REPLICAS=1
  # Then
  check 1

}

function test-persistent()
{
  # Given
  # When
  oc new-app zk-persistent -p ZOO_REPLICAS=3
  # Then
  check 3
}

function test-all()
{
  test && oc delete -l component=zk -l zk-name=zk all,pv,pvc,statefulset
  test-persistent && oc delete -l component=zk -l zk-name=zk all,pv,pvc,statefulset
}

function oc-cluster-clean()
{
  echo "Cleaning ...."
  oc cluster down
}

function help() # Show a list of functions
{
    declare -F -p | cut -d " " -f 3
}

if [ "_$1" = "_" ]; then
    help
else
    "$@"
fi
