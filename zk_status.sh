#!/bin/bash -e

ZK_clientPort=${ZK_clientPort:-2181}
OK=$(echo ruok | nc 127.0.0.1 $ZK_clientPort)
if [ "$OK" == "imok" ]; then
  exit 0
else
  exit 1
fi