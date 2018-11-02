#!/usr/bin/env bash

set -e

MINIKUBE_VERSION=${MINIKUBE_VERSION:-"v0.30.0"}
KUBE_VERSION=${KUBE_VERSION:-"v1.10.0"}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DISTRO=$(uname -s | tr '[:upper:]' '[:lower:]')

function kubectl-install()
{

  if [[ "${KUBE_VERSION}" == 'latest' ]]; then
    KUBE_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
  fi

  # Download kubectl
  curl -L -o kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/$DISTRO/amd64/kubectl
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  mkdir -p ${HOME}/.kube
  touch ${HOME}/.kube/config

}

function minikube-install()
{
  # Download minikube
  curl -L -o minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-$DISTRO-amd64
  chmod +x minikube
  sudo mv minikube /usr/local/bin/

}

function minikube-run()
{

  export MINIKUBE_WANTUPDATENOTIFICATION=false
  export MINIKUBE_WANTREPORTERRORPROMPT=false
  export MINIKUBE_HOME=$HOME
  export CHANGE_MINIKUBE_NONE_USER=true
  export KUBECONFIG=$HOME/.kube/config

  sudo -E minikube start --vm-driver=none --cpus 2 --memory 2048 --kubernetes-version=${KUBE_VERSION}

  # this for loop waits until kubectl can access the api server that Minikube has created
  for i in {1..150}; do # timeout for 5 minutes
     kubectl version &> /dev/null
     if [ $? -ne 1 ]; then
        break
    fi
    sleep 2
  done

  # Check kubernetes info
  kubectl cluster-info
  # RBAC
  kubectl create clusterrolebinding add-on-cluster-admin --clusterrole cluster-admin --serviceaccount=kube-system:default
  # Install Helm
  # curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
}

# $1 : file
# $2 : Number of replicas
function check()
{
  SLEEP_TIME=10
  MAX_ATTEMPTS=10
  ATTEMPTS=0
  JSONPATH_STSETS=
  until [ "$(kubectl get -f $1 -o jsonpath='{.items[?(@.kind=="StatefulSet")].status.readyReplicas}' 2>&1)" == "$2" ]; do
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
  # When
  kubectl create -f $file
  # Then
  check $file 1

}

function test-persistent()
{
  # Given
  file=$DIR/zk-persistent.yaml
  # When
  kubectl create -f $file
  # Then
  check file 3
}

function test-all()
{
  test && kubectl delete --force=true -l component=zk -l app=zk all
  test-persistent && kubectl delete --force=true -l component=zk -l app=zk all,pv,pvc
}

function clean() # Destroy minikube vm
{
  echo "Cleaning ...."
  sudo minikube delete
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
