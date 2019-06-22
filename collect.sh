# incomplete
#
#!/bin/bash
#
#

################################################################################

_tstamp=$1                      # Unique timestamp for a collection of diags
_tstamp=`date -u +%Y%m%d_%H%M%S`

_iterations=10                  # number of iterations
_delay=10                       # delay between collections
_dt=`date -u +%Y%m%d_%H%M%S`    # Date Time from local node
_diagdir=dsediag.${_tstamp}     # Directory used to collect diags
_diaglog=dsediag.log            # Log file for this colelction script

################################################################################
function collect_once {
# Run this at the end to collect logs and other one time arrtifacts
# collect at the end, to encompase the logs which were active during the collection

  log "DSE Version - `dse -v`"
  log "Running collect_once ..."
  nodetool status > nodetool_status

}

################################################################################
function collect {
# collect certain artifacts at a lesser frequency
  log "Running collect - `date -u +%Y%m%d_%H%M%S`"
}

################################################################################
function tar_and_tidy {
  cd /tmp
  [ -d $_diagdir ] && tar czf dse_diags.tar.gz $_diagdir/*
  #[ -d $_diagdir ] && rm -rf _diagdir
}

################################################################################
function log {
  echo $1 >> /tmp/${_diagdir}/${_diaglog}
}
################################################################################
# main

  echo Starting ...
  [ ! -d /tmp/${_diagdir} ] && mkdir /tmp/${_diagdir}
  cd /tmp/${_diagdir}
  log "Start logging - `date -u +%Y%m%d_%H:%M:%S`"
  log "Host - `hostname -I`"

  while [ $_iterations -gt 1 ]; do
    collect
    ((_iterations-=1))
    sleep $_delay
  done

  collect_once

  log "End logging - `date -u +%Y%m%d_%H:%M:%S`"
  tar_and_tidy

exit 0

[ ! -f nodetool.status ] && nodetool status > nodetool.status

for i in `cat nodetool.status | grep ^UN | awk '{print $2}'`
do
  scp trace.cql automaton@$i:/home/automaton/trace.cql
  ssh $i "cqlsh -f /home/automaton/trace.cql > trace.log"
  scp automaton@$i:/home/automaton/trace.log trace-$i.log
done
for i in `cat nodetool.status | grep ^UN | awk '{print $2}'`
do
  scp trace.cql automaton@$i:/home/automaton/trace.cql

  ssh $i "cqlsh -f /home/automaton/trace.cql > trace.log"
  scp automaton@$i:/home/automaton/trace.log trace-$i.log
done

# Run a local srript on a remone node
ssh remoteuser@ip.address.of.server 'bash -s' < scriptfile.sh

# Send / Receive file
cat file | ssh remoteuser@ip.address.of.remote.machine "cat > remote"
ssh remoteuser@ip.address.of.remote.machine "cat > remote" < file
