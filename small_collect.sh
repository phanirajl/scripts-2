#!/bin/bash
# script to collect a subset of diags 

_hname=`hostname -I | sed 's/ //g'`
_logdir=/var/log
_confdir=/etc/dse

mkdir /tmp/diags_${_hname}
cd /tmp/diags_${_hname}
mkdir logs
mkdir logs/cassandra
mkdir logs/spark
mkdir nodetool
mkdir dsetool
mkdir conf

nodetool status > nodetool/status.txt
nodetool info > nodetool/info.txt
nodetool cfstats > nodetool/cfstats.txt
nodetool tpstats > nodetool/tpstats.txt
dsetool ring > dsetool/ring.txt

cp $_logdir/cassandra/system.log logs/cassandra
cp $_logdir/cassandra/debug.log logs/cassandra
cp $_logdir/cassandra/output.log logs/cassandra
sudo cp $_logdir/spark/master/master.log logs/spark
sudo cp $_logdir/spark/worker/worker.log logs/spark

cp $_confdir/dse.yaml conf
cp $_confdir/cassandra/cassandra.yaml conf
cp $_confdir/cassandra/cassandra-env.sh conf

tar czf "diags_${_hname}.tar.gz" *
ls -l "diags_${_hname}.tar.gz"
