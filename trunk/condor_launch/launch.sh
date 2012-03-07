#!/bin/bash

expirationInHoursDefault=24
cpuNoMultiplierDefault=1
memoryRequiredDefault=10
if test $# -lt 1 ; then
	echo "  $0 [expirationInHours] [noOfCPUs] [memoryRequired] [cpuNoMultiplier] [condorHost]"
	echo ""
	echo "Note:"
	echo "	#. expirationInHours is the number of hours for the slave to remain alive. Default is $expirationInHoursDefault."
	echo "	#. noOfCPUs is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is what condor detects."
	echo "  #. condorHost is the machine where collector,negotiator, etc. are running. Omit means the machine itself is the host"
	echo "	#. cpuNoMultiplier is to let condor claim it has noOfCPUs*cpuNoMultiplier cpus. Default is $cpuNoMultiplierDefault."
	echo "	#. memoryRequired is the amount of memory needed for this job in unit of Giga-byte. Default is $memoryRequiredDefault. Final memory that condor will broadcast is memoryRequired*noOfCPUs."
	exit 1
fi
set -e
expirationInHours=$1
noOfCPUs=$2
memoryRequired=$3
cpuNoMultiplier=$4
condorHost=$5
thisIsSlave=0
if [ "x$condorHost" = "x" ]; then
	echo "No master host given - assuming I'm the new master!"
	CONDOR_HOST=`hostname -f`
	CONDOR_DAEMON_LIST="MASTER, COLLECTOR, NEGOTIATOR, STARTD, SCHEDD"
	thisIsSlave=0
	echo "When registering workers, please specify $CONDOR_HOST as the central manager"
else
	echo "Starting worker for the master at $condorHost"
	CONDOR_HOST=$condorHost
	CONDOR_DAEMON_LIST="MASTER, STARTD"
	thisIsSlave=1
fi


if [ "x$expirationInHours" = "x" ]; then
	echo "No expirationInHours given. set it to $expirationInHoursDefault."
	expirationInHours=$expirationInHoursDefault;
else
	echo "expirationInHours set to $expirationInHours."
fi

expirationInMins=`echo whatever|awk '{print '$expirationInHours'*60}'`;
echo condor daemon will expire after $expirationInMins minutes.

if [ "x$noOfCPUs" = "x" ]; then
	echo "No noOfCPUs given. set it to \$(DETECTED_CORES)"
	noOfCPUs="\$(DETECTED_CORES)";
else
	echo "noOfCPUs set to $noOfCPUs."
fi

if [ -z $cpuNoMultiplier ]
then
	cpuNoMultiplier=$cpuNoMultiplierDefault
fi

if [ -z $memoryRequired ]
then
	memoryRequired=$memoryRequiredDefault
fi

echo "condor will claim $cpuNoMultiplier\X as many cpus available."
# condor folder to use
CONDOR=condor

# this will contain logs/execute/spool
currentUnixTime=`echo "import time; print time.time()"|python`
# 2011-11-26 stop attaching currentUnixTime to LOCAL_DIR. because it makes exporting CONDOR_CONFIG on master node complicated.
if test "$thisIsSlave" = "0"; then
	LOCAL_DIR=/work/polyacti/condor
else
	LOCAL_DIR=/work/polyacti/condor$currentUnixTime
fi

#clean up the condor conf folder
rm -rf $LOCAL_DIR/*

TOP_DIR=`dirname $0`
TOP_DIR=`cd $TOP_DIR && pwd`

mkdir -p $LOCAL_DIR/execute
mkdir -p $LOCAL_DIR/log
mkdir -p $LOCAL_DIR/spool

# create an env file for easy sourcing
cat >$LOCAL_DIR/env.sh <<EOF
#!/bin/bash
export PATH=$TOP_DIR/$CONDOR/bin:$TOP_DIR/$CONDOR/sbin:$PATH
export CONDOR_CONFIG=$LOCAL_DIR/condor_config
EOF

. $LOCAL_DIR/env.sh

# fix the condor config file
cp $TOP_DIR/condor_config $TOP_DIR/condor_config.local $LOCAL_DIR/
perl -p -i -e "s:^RELEASE_DIR.*:RELEASE_DIR = $TOP_DIR/$CONDOR:" $LOCAL_DIR/condor_config
perl -p -i -e "s:^LOCAL_DIR( |\t).*:LOCAL_DIR = $LOCAL_DIR:" $LOCAL_DIR/condor_config

memoryRequiredInMB=`echo $memoryRequired*$noOfCPUs*1024|bc`
#2012.2.27 setup proper memory
echo "SLOT_TYPE_1 = cpus=100%, memory=$memoryRequiredInMB " >>$LOCAL_DIR/condor_config.local
#2011.12.13 cheating, fake 3 times of cpus requested
echo "NUM_CPUS=$noOfCPUs*$cpuNoMultiplier" >>$LOCAL_DIR/condor_config.local
#echo "NUM_CPUS=$noOfCPUs" >>$LOCAL_DIR/condor_config.local
echo "CONDOR_HOST=$CONDOR_HOST" >>$LOCAL_DIR/condor_config.local
echo "FILESYSTEM_DOMAIN=$CONDOR_HOST" >>$LOCAL_DIR/condor_config.local
echo "DAEMON_LIST=$CONDOR_DAEMON_LIST" >>$LOCAL_DIR/condor_config.local

# 2012.3.6 kill jobs immediately after preempt (when it's near the daemon exit time)
echo "PREEMPT = (CurrentTime - JobStart) > ($expirationInHours*\$(HOUR)-5*\$(MINUTE))" >>$LOCAL_DIR/condor_config.local
echo "WANT_VACATE = FALSE" >>$LOCAL_DIR/condor_config.local
#echo "KILL = TRUE # No longer matters" >>$LOCAL_DIR/condor_config.local
#echo "KILL = (\$(CurrentTime) - \$(DaemonStartTime)) > $expirationInHours*\$(HOUR)" >>$LOCAL_DIR/condor_config.local
if test "$thisIsSlave" = "1"
then
	#differentiate between different STARTD processes on the same machine
	machineName=`hostname -f`
	echo "STARTD_NAME=slave$currentUnixTime" >>$LOCAL_DIR/condor_config.local
fi

condor_master -f -r $expirationInMins

#-f: Causes the daemon to start up in the foreground. Instead of forking, the daemon runs in the foreground.
#-r MINUTES: Causes the daemon to set a timer, upon expiration of which, it sends itself a SIGTERM for graceful shutdown.

