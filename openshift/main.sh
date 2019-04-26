#!/usr/bin/env bash

set -e

ZK_VERSION=${ZK_VERSION:-"3.4.14"}
ZK_IMAGE="engapa/zookeeper:${ZK_VERSION}"

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
     if [[ $? -ne 1 ]]; then
        break
    fi
    sleep 2
  done

  oc login -u system:admin
  oc create -f  $DIR/scc.yaml
  oc adm policy add-scc-to-group zookeeper-scc system:serviceaccounts:myproject
  oc adm policy add-scc-to-group privileged system:serviceaccounts:myproject
  oc create -f $DIR/zk.yaml
  oc create -f $DIR/zk-persistent.yaml

}

function build_local_image()
{

  oc new-build --name zk --strategy docker --binary --docker-image "openjdk:8-jre-alpine"
  oc start-build zk --from-dir $DIR/.. --follow

}

# $1 : Number of replicas
function check()
{

  SLEEP_TIME=10
  MAX_ATTEMPTS=50
  ATTEMPTS=0
  until [[ "$(oc get statefulset -l component=zk -o jsonpath='{.items[?(@.kind=="StatefulSet")].status.currentReplicas}' 2>&1)" == "$1" ]]; do
    sleep $SLEEP_TIME
    ATTEMPTS=`expr $ATTEMPTS + 1`
    if [[ $ATTEMPTS -gt $MAX_ATTEMPTS ]]; then
      echo "ERROR: Max number of attempts was reached (${MAX_ATTEMPTS})"
      exit 1
    fi
   echo "Retry [${ATTEMPTS}/${MAX_ATTEMPTS}] ... "
  done
  oc get all
}

function test()
{
  # Given
  ZOO_REPLICAS=${1:-1}
  # When
  oc new-app --template=zk -p ZOO_REPLICAS=${ZOO_REPLICAS} -p SOURCE_IMAGE="engapa/zookeeper"
  # Then
  check ${ZOO_REPLICAS}

}

function test-persistent()
{
  # Given
  ZOO_REPLICAS=${1:-1}
  for i in $(seq 1 ${ZOO_REPLICAS});do
  cat << PV | oc create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
 name: zk-persistent-data-disk-$i
 contents: data
 labels:
   component: zk
spec:
 capacity:
  storage: 1Gi
 accessModes:
  - ReadWriteOnce
 hostPath:
  path: /tmp/oc/zk-persistent-data-disk-$i
PV
  cat << PVLOG | oc create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
 name: zk-persistent-datalog-disk-$i
 contents: datalog
 labels:
   component: zk
spec:
 capacity:
  storage: 1Gi
 accessModes:
  - ReadWriteOnce
 hostPath:
  path: /tmp/oc/zk-persistent-datalog-disk-$i
PVLOG
  done
  # When
  oc new-app --template=zk-persistent -p ZOO_REPLICAS=${ZOO_REPLICAS} -p SOURCE_IMAGE="engapa/zookeeper"
  # Then
  check ${ZOO_REPLICAS}
  oc get pv,pvc

}

function test-all()
{
  ZOO_REPLICAS=$1
  test $ZOO_REPLICAS && oc delete -l component=zk all
  test-persistent $ZOO_REPLICAS && oc delete -l component=zk all,pv,pvc
}

function clean-resources()
{
  echo "Cleaning resources ...."
  oc delete -l component=zk all,pv,pvc
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

if [[ "_$1" = "_" ]]; then
    help
else
    "$@"
fi
