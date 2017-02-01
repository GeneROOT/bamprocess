#! /bin/bash

#set -x

host=`hostname`
nodelist="../../doc/CERNmachine_list.txt"
node=`grep $host $nodelist | cut -f 1`
if [ "x$node" == "x" ]; then
   echo "$host not found in $nodelist..."
   exit 1
fi
time=`date "+%Y%m%d%H%M"`

echo "nohup sh ./run_bamToFastq.sh $node &> /eos/genome/local/14007a/logs/log_machine${node}_${time}.log &"
nohup sh ./run_bamToFastq.sh $node &> /eos/genome/local/14007a/logs/log_machine${node}_${time}.log &

exit 0
