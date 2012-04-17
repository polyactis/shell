#!/bin/bash

cpuNoMultiplierDefault=1
memoryRequiredDefault=10
memoryMultiplierDefault=1
sshDBTunnelDefault=0
if test $# -lt 1 ; then
	echo "  $0 [noOfCPUs] [memoryRequired] [cpuNoMultiplier] [memoryMultiplier] [sshDBTunnel] [condorHost]"
	echo ""
	echo "Note:"
	echo "	#. noOfCPUs is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is what condor detects."
	echo "	#. cpuNoMultiplier is to let condor claim it has noOfCPUs*cpuNoMultiplier cpus. Default is $cpuNoMultiplierDefault."
	echo "	#. memoryRequired is the amount of memory needed for this job in unit of Giga-byte. Default is $memoryRequiredDefault. Final memory that condor will broadcast is memoryRequired*noOfCPUs."
	echo "	#. memoryMultiplier is to let condor claim it has memoryRequired*memoryMultiplier memory. Default is $memoryMultiplierDefault."
	echo "	#. sshDBTunnel is the variable added to the machine classAd. If =1, means this machine has a ssh tunnel to access psql db on dl324b-1. Otherwise (=0 or non-1), it does not. Make sure run ~/script/shell/sshTunnelForDB.sh on =1 machines. Default value is $sshDBTunnelDefault"
	echo "  #. condorHost is the condor central manager. If it is "-", hostname of the machine itself is taken as central manager. If not provided, it will try to read the central manager from ~/condor_central_manager.txt or become central manager on its own if the latter file is empty or non-existent."
	exit 1
fi
set -e
noOfCPUs=$1
memoryRequired=$2
cpuNoMultiplier=$3
memoryMultiplier=$4
sshDBTunnel=$5
condorHost=$6

centralManagerFilename=~/condor_central_manager.txt

thisIsSlave=0
if [ "x$condorHost" = "x-" ]; then
	#echo "No master host given - assuming I'm the new master!"
	CONDOR_HOST=`hostname -f`
	CONDOR_DAEMON_LIST="MASTER, COLLECTOR, NEGOTIATOR, STARTD, SCHEDD"
	thisIsSlave=0
elif [ "x$condorHost" = "x" ]; then
	if test -f $centralManagerFilename; then
		condorHost=`cat $centralManagerFilename`
	fi
	if [ "x$condorHost" = "x" ]; then
		#echo "No master host given - assuming I'm the new master!"
		CONDOR_HOST=`hostname -f`
		CONDOR_DAEMON_LIST="MASTER, COLLECTOR, NEGOTIATOR, STARTD, SCHEDD"
		thisIsSlave=0
		#echo "When registering workers, please specify $CONDOR_HOST as the central manager"
	else
		#echo "Starting worker for the master at $condorHost"
		CONDOR_HOST=$condorHost
		CONDOR_DAEMON_LIST="MASTER, STARTD"
		thisIsSlave=1
	fi
else
	#echo "Starting worker for the master at $condorHost"
	CONDOR_HOST=$condorHost
	CONDOR_DAEMON_LIST="MASTER, STARTD"
	thisIsSlave=1
fi


if [ "x$noOfCPUs" = "x" ]; then
	#echo "No noOfCPUs given. set it to \$(DETECTED_CORES)"
	noOfCPUs="\$(DETECTED_CORES)";
fi
#echo "noOfCPUs set to $noOfCPUs."

if [ -z $cpuNoMultiplier ]
then
	cpuNoMultiplier=$cpuNoMultiplierDefault
fi

if [ -z $memoryRequired ]
then
	memoryRequired=$memoryRequiredDefault
fi

if [ -z $memoryMultiplier ]
then
	memoryMultiplier=$memoryMultiplierDefault
fi

if [ -z $sshDBTunnel ]
then
	sshDBTunnel=$sshDBTunnelDefault
fi


#echo "condor will claim $cpuNoMultiplier\X as many cpus available."
#2012.3.29 -17Mb for each 1G because not all memory is available to the userspace condor daemon. i.e. a 32Gb machine has 530Mb memory unavailable.
memoryRequiredInMB=`echo $memoryRequired*$noOfCPUs*\(1024-17\)|bc`

memoryRequiredAfterMultiplying=`echo $memoryRequiredInMB*$memoryMultiplier|bc`
noOfCPUsAfterMultiplying=`echo $noOfCPUs*$cpuNoMultiplier|bc`

# condor folder to use
CONDOR=condor

# this will contain logs/execute/spool
currentUnixTime=`echo "import time; print time.time()"|python`

localCondorConfigFile=/tmp/condor$currentUnixTime.condor_config.local
# provide a backbone local config file
TOP_DIR=`dirname $0`
TOP_DIR=`cd $TOP_DIR && pwd`
cp $TOP_DIR/condor_config.local $localCondorConfigFile

#2012.2.27 setup proper memory
echo "SLOT_TYPE_1 = cpus=100%, memory=$memoryRequiredAfterMultiplying " >>$localCondorConfigFile
#2011.12.13 report the number of cpus after multiplying
echo "NUM_CPUS=$noOfCPUsAfterMultiplying" >>$localCondorConfigFile
echo "CONDOR_HOST=$CONDOR_HOST" >>$localCondorConfigFile
echo "FILESYSTEM_DOMAIN=$CONDOR_HOST" >>$localCondorConfigFile
echo "DAEMON_LIST=$CONDOR_DAEMON_LIST" >>$localCondorConfigFile
#2012.4.16 add sshDBTunnel classAd for this machine
echo "sshDBTunnel=$sshDBTunnel" >>$localCondorConfigFile
echo "STARTD_ATTRS = \$(STARTD_ATTRS) sshDBTunnel" >>$localCondorConfigFile
# 2012.3.6 kill jobs immediately after preempt (when it's near the condor_master expiration time)
#echo "PREEMPT = (CurrentTime - DaemonStartTime) > ($expirationInHours*\$(HOUR)-10*\$(MINUTE))" >>$localCondorConfigFile
#echo "WANT_VACATE = FALSE" >>$localCondorConfigFile
#echo "KILL = TRUE # No longer matters" >>$localCondorConfigFile
#echo "KILL = (\$(CurrentTime) - \$(DaemonStartTime)) > $expirationInHours*\$(HOUR)" >>$LOCAL_DIR/condor_config.local
if test "$thisIsSlave" = "1"
then
	#differentiate between different STARTD processes on the same machine
	machineName=`hostname -f`
	echo "STARTD_NAME=$machineName.S$currentUnixTime" >>$localCondorConfigFile
fi
#echo "ALL_DEBUG = D_ALL" >> $localCondorConfigFile
#echo "STARTD_DEBUG=D_FULLDEBUG" >> $localCondorConfigFile
cat $localCondorConfigFile
