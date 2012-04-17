#!/bin/bash

expirationInHoursDefault=24
cpuNoMultiplierDefault=1
memoryRequiredDefault=10
memoryMultiplierDefault=1
sshDBTunnelDefault=0
if test $# -lt 1 ; then
	echo "  $0 [expirationInHours] [noOfCPUs] [memoryRequired] [cpuNoMultiplier] [memoryMultiplier] [sshDBTunnel] [condorHost]"
	echo ""
	echo "Note:"
	echo "	#. expirationInHours is the number of hours for the slave to remain alive. Default is $expirationInHoursDefault."
	echo "	#. noOfCPUs is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is what condor detects."
	echo "	#. cpuNoMultiplier is to let condor claim it has noOfCPUs*cpuNoMultiplier cpus. Default is $cpuNoMultiplierDefault."
	echo "	#. memoryRequired is the amount of memory needed for this job in unit of Giga-byte. Default is $memoryRequiredDefault. Final memory that condor will broadcast is memoryRequired*noOfCPUs."
	echo "	#. memoryMultiplier is to let condor claim it has memoryRequired*memoryMultiplier memory. Default is $memoryMultiplierDefault."
	echo "	#. sshDBTunnel is the variable added to the machine classAd. If =1, means this machine has a ssh tunnel to access psql db on dl324b-1. Otherwise (=0 or non-1), it does not. Make sure run ~/script/shell/sshTunnelForDB.sh on =1 machines. Default value is $sshDBTunnelDefault"
	echo "	#. condorHost is the condor central manager. If it is "-", hostname of the machine itself is taken as central manager. If not provided, it will try to read the central manager from ~/condor_central_manager.txt or become central manager on its own if the latter file is empty or non-existent."
	exit 1
fi
set -e
expirationInHours=$1
noOfCPUs=$2
memoryRequired=$3
cpuNoMultiplier=$4
memoryMultiplier=$5
sshDBTunnel=$6
condorHost=$7
centralManagerFilename=~/condor_central_manager.txt

thisIsSlave=0

machineName=`hostname -f`
echo "Running on $machineName ..."

if [ "x$condorHost" = "x-" ]; then
	thisIsSlave=0
elif [ "x$condorHost" = "x" ]; then
	if test -f $centralManagerFilename; then
		anything=`cat $centralManagerFilename`
		#don't change the value of condorHost.
	fi
	if [ "x$anything" = "x" ]; then
		thisIsSlave=0
	else
		thisIsSlave=1
	fi
else
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

if [ -z $memoryMultiplier ]
then
	memoryMultiplier=$memoryMultiplierDefault
fi

if [ -z $sshDBTunnel ]
then
	sshDBTunnel=$sshDBTunnelDefault
fi

echo "condor will claim $cpuNoMultiplier\X as many cpus available."
#2012.3.29 -17Mb for each 1G because not all memory is available to the userspace condor daemon. i.e. a 32Gb machine has 530Mb memory unavailable.
echo "memoryRequired is $memoryRequired. noOfCPUs is $noOfCPUs."
memoryRequiredInMB=`echo $memoryRequired*$noOfCPUs*\(1024-17\)|bc`

memoryRequiredAfterMultiplying=`echo $memoryRequiredInMB*$memoryMultiplier|bc`
noOfCPUsAfterMultiplying=`echo $noOfCPUs*$cpuNoMultiplier|bc`

# condor folder to use
CONDOR=condor

# this will contain logs/execute/spool
currentUnixTime=`echo "import time; print time.time()"|python`
# 2011-11-26 stop attaching currentUnixTime to LOCAL_DIR. because it makes exporting CONDOR_CONFIG on master node complicated.
if test "$thisIsSlave" = "0"; then
	LOCAL_DIR=/work/polyacti/condorM$currentUnixTime
else
	LOCAL_DIR=/work/polyacti/condorS$currentUnixTime
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
cp $TOP_DIR/condor_config $LOCAL_DIR/
perl -p -i -e "s:^RELEASE_DIR.*:RELEASE_DIR = $TOP_DIR/$CONDOR:" $LOCAL_DIR/condor_config
perl -p -i -e "s:^LOCAL_DIR( |\t).*:LOCAL_DIR = $LOCAL_DIR:" $LOCAL_DIR/condor_config
perl -p -i -e "s:^LOCAL_CONFIG_FILE( |\t).*:LOCAL_CONFIG_FILE = $TOP_DIR/makeCondorConfig.sh $noOfCPUs $memoryRequired $cpuNoMultiplier $memoryMultiplier $sshDBTunnel $condorHost|:" $LOCAL_DIR/condor_config

condor_master -f -r $expirationInMins

#-f: Causes the daemon to start up in the foreground. Instead of forking, the daemon runs in the foreground.
#-r MINUTES: Causes the daemon to set a timer, upon expiration of which, it sends itself a SIGTERM for graceful shutdown.

