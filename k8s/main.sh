#!/usr/bin/env bash

set -e

ZK_VERSION=${ZK_VERSION:-"3.4.13"}
ZK_IMAGE=${ZK_IMAGE:-"engapa/zookeeper:${ZK_VERSION}"}
MINIKUBE_VERSION=${MINIKUBE_VERSION:-"v0.28.2"}
KUBE_VERSION=${KUBE_VERSION:-"v1.11.3"}

CHANGE_MINIKUBE_NONE_USER="true"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SLEEP_TIME=8
MAX_ATTEMPTS=10

DISTRO=$(uname -s | tr '[:upper:]' '[:lower:]')

function kubectl()
{

  if [[ "${KUBE_VERSION}" == 'latest' ]]; then
    KUBE_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
  fi

  # Download kubectl
  curl -LO kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/$DISTRO/amd64/kubectl
  chmod +x kubectl

}

function minikube()
{
  # Download minikube
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-$DISTRO-amd64
  chmod +x minikube

}

function minikube-run()
{

  export MINIKUBE_WANTUPDATENOTIFICATION=false
  export MINIKUBE_WANTREPORTERRORPROMPT=false
  export MINIKUBE_HOME=$HOME
  export CHANGE_MINIKUBE_NONE_USER=true
  mkdir -p $HOME/.kube
  touch $HOME/.kube/config

  export KUBECONFIG=$HOME/.kube/config
  sudo -E ./minikube start --memory 5000 --cpus 4

  # this for loop waits until kubectl can access the api server that Minikube has created
  for i in {1..150}; do # timeout for 5 minutes
     ./kubectl version &> /dev/null
     if [ $? -ne 1 ]; then
        break
    fi
    sleep 2
  done

  # Check kubernetes info
  ./kubectl cluster-info
}

function conf()
{

  sed -i -e "s/image:.*/image: $ZK_IMAGE/" $1

}

# $1: zookeper image
function zk_install()
{

  echo "Deploying zookeeper ..."
  ./kubectl run zk --image $ZK_IMAGE --port 2181 --labels="component=zk"
  ./kubectl expose deploy zk --name zk --port=2181 --cluster-ip=None --labels="component=zk"
  echo "Zookeeper running on zk.<namespace>.svc.cluster.local"

}

# $1 : file
# $2 : Number of replicas
function check()
{

  attempts=0
  JSONPATH_STSETS='replicasOk={.items[?(@.kind=="StatefulSet")].status.readyReplicas}'
  until [ "$(./kubectl get -f $1 -o jsonpath="$JSONPATH_STSETS" 2>&1)" == "replicasOk=$2" ]; do
    sleep $SLEEP_TIME
    attempts=`expr $attempts + 1`
    if [[ $attempts -gt $MAX_ATTEMPTS ]]; then
      echo "ERROR: Max number of attempts was reached (${MAX_ATTEMPTS})"
      exit 1
    fi
   echo "Retry [${attempts}] ... "
  done
}

function test()
{
  # Given
  file=$DIR/zookepper.yaml
  conf $file
  # When
  ./kubectl create -f $file
  # Then
  check $file 3
  # TODO: Use zookeeper client to validate e2e
}

function test-persistent()
{
  # Given
  file=$DIR/zk-persistent.yaml
  # When
  ./kubectl create -f $file
  # Then
  check file 1
}

function test-all()
{
  test && ./kubectl delete --force=true -l component=zk -l app=zk all
  test-persistent && ./kubectl delete --force=true -l component=zk -l app=zk all,pv,pvc
}

function clean() # Destroy minikube vm
{
  echo "Cleaning ...."
  ./minikube delete
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
