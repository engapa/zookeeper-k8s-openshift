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

function minishift-install()
{
  # Download minishift
  curl -LO https://github.com/minishift/minishift/releases/download/v1.26.1/minishift-1.26.1-linux-amd64.tgz
  tar -xzf minishift-1.26.1-linux-amd64.tgz
  mv minishift-1.26.1-linux-amd64/minishift ./minishift
  rm -rf minishift-*
  chmod a+x minishift
  sudo mv minishift /usr/local/bin/minishift
}

function minishift-run()
{

  export MINISHIFT_HOME=$HOME
  export CHANGE_MINISHIFT_NONE_USER=true
  mkdir -p $HOME/.kube
  touch $HOME/.kube/config

  export KUBECONFIG=$HOME/.kube/config
  sudo -E ./minishift start --vm-driver=none --cpus 2

  # Waiting for Minikube
  for i in {1..150}; do # timeout for 5 minutes
     oc version &> /dev/null
     if [ $? -ne 1 ]; then
        break
    fi
    sleep 2
  done

}

# $1: zookeper image
function zk_install()
{

  echo "Deploying zookeeper ..."
  oc run zk --image $ZK_IMAGE --port 2181 --labels="component=zk,zk-name=zk"
  oc expose deploy zk --name zk --port=2181 --cluster-ip=None --labels="component=zk,app=zk"
  echo "Zookeeper running on zk.<namespace>.svc.cluster.local"

}

# $1 : file
# $2 : Number of replicas
function check()
{

  SLEEP_TIME=8
  MAX_ATTEMPTS=10
  ATTEMPTS=0
  until [ "$(oc get -f $1 -o jsonpath='{.items[?(@.kind=="StatefulSet")].status.readyReplicas}' 2>&1)" == "replicasOk=$2" ]; do
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
  file=$DIR/zk.yaml
  conf $file
  # When
  oc create -f $file
  oc new-app zk -p REPLICAS=1
  # Then
  check $file 3
  # TODO: Use zookeeper client to validate e2e
}

function test-persistent()
{
  # Given
  install_zk
  file=$DIR/zk-persistent.yaml
  # When
  oc create -f $file
  oc new-app zk -p REPLICAS=1
  # Then
  check $file 3
}

function test-all()
{
  test && oc delete --force=true -l component=zk -l zk-name=zk all
  test-persistent && oc delete --force=true -l component=zk -l zk-name=zk all,pv,pvc
}

function clean() # Destroy minishift vm
{
  echo "Cleaning ...."
  minishift delete
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
