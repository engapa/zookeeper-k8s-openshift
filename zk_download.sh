#!/bin/bash -e

function download_zoo_release () {

  if [[ -z $ZOO_VERSION || -z $ZOO_HOME ]]; then
    echo 'ZOO_VERSION and ZOO_HOME are required values.' && exit 1;
  fi

  URL_PREFIX="https://dist.apache.org/repos/dist/release/zookeeper/zookeeper-${ZOO_VERSION}/zookeeper-${ZOO_VERSION}"

  wget -q -O /tmp/zookeeper.tar.gz "${URL_PREFIX}.tar.gz"
  wget -q -O /tmp/zookeeper.tar.gz.asc "${URL_PREFIX}.tar.gz.asc"

  wget -q -O /tmp/KEYS https://dist.apache.org/repos/dist/release/zookeeper/KEYS
  gpg -q --import /tmp/KEYS

  gpg -q --verify /tmp/zookeeper.tar.gz.asc /tmp/zookeeper.tar.gz
  tar -xzf /tmp/zookeeper.tar.gz --strip-components 1 -C $ZOO_HOME

  rm -rf /tmp/zookeeper.tar.{gz, gz.asc} \
         /tmp/KEYS
  rm -rf $ZOO_HOME/{CHANGES.txt,NOTICE.txt,LICENSE.txt,README*} \
         $ZOO_HOME/build* \
         $ZOO_HOME/ivy* \
         $ZOO_HOME/recipes \
         $ZOO_HOME/src \
         $ZOO_HOME/dist-maven \
         $ZOO_HOME/docs \
         $ZOO_HOME/bin/{*.cmd,README.txt} \
         $ZOO_HOME/*.{asc,md5,sha1}
}

function download_utils() {
  wget -q -O $ZOO_HOME/common_functions.sh https://raw.githubusercontent.com/engapa/utils-docker/master/common-functions.sh
}

download_utils && download_zoo_release