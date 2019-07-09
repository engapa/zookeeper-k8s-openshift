#!/bin/bash -e

if [[ -z $ZOO_VERSION || -z $ZOO_HOME ]]; then
  echo 'ZOO_VERSION and ZOO_HOME are required values.' && exit 1;
fi

function download_zoo_release () {

  URL_BASE="https://dist.apache.org/repos/dist/release/zookeeper"
  URL_DIST="${URL_BASE}/zookeeper-${ZOO_VERSION}/apache-zookeeper-${ZOO_VERSION}-bin.tar.gz"

  wget -q -O /tmp/zookeeper.tar.gz "${URL_DIST}"
  wget -q -O /tmp/zookeeper.tar.gz.asc "${URL_DIST}.asc"

  wget -q -O /tmp/KEYS "${URL_BASE}/KEYS"
  gpg -q --import /tmp/KEYS

  gpg -q --verify /tmp/zookeeper.tar.gz.asc /tmp/zookeeper.tar.gz
  tar -xzf /tmp/zookeeper.tar.gz --strip-components 1 -C $ZOO_HOME

  rm -rf /tmp/zookeeper.tar.{gz, gz.asc} \
         /tmp/KEYS
  rm -rf $ZOO_HOME/{NOTICE.txt,LICENSE.txt,README*} \
         $ZOO_HOME/docs \
         $ZOO_HOME/bin/{README*,*.cmd}
}

function download_utils() {
  wget -q -O $ZOO_HOME/common_functions.sh https://raw.githubusercontent.com/engapa/utils-docker/master/common-functions.sh
  chmod a+x $ZOO_HOME/common_functions.sh
}

download_utils && download_zoo_release