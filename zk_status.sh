#!/bin/bash -e

ZK_clientPort=${ZK_clientPort:-2181}
OK=$(echo ruok | nc 127.0.0.1 $ZK_clientPort)
if [ "$OK" == "imok" ]; then
  echo -e "\033[32mZookeeper server is running, :-)\033[0m"
  exit 0
else
  echo -e "\033[31mZookeeper server is not running, :-(\033[0m"
  exit 1
fi