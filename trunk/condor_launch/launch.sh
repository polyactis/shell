#!/bin/bash

#2012.7.31 increase the max number of processes per user for this shell so that it could spawn lots of condor_shadow
source ~/.bashrc
#ulimit -u 50000
#ulimit -n 50000

shellDir=`dirname $0`
source $shellDir/common.sh

expirationInHoursDefault=24
expirationInHoursOptionDesc="	#. expirationInHours is the number of hours for the slave to remain alive. Default is $expirationInHoursDefault."

if test $# -lt 1 ; then
	echo "  $0 [noOfCPUs] [memoryRequired] [cpuNoMultiplier] [memoryMultiplier] [sshDBTunnel] [GLIDEIN_MAX_IDLE_HOURS] [condorCM]  [cmNumber] [expirationInHours] "
	echo ""
	echo "Note:"
	echo "$noOfCPUsOptionDesc"
	echo "$cpuNoMultiplierOptionDesc "
	echo "$memoryRequiredOptionDesc"
	echo "$memoryMultiplierOptiondesc"
	echo "$sshDBTunnelOptionDesc"
	echo "$GLIDEIN_MAX_IDLE_HOURSOptionDesc"
	echo "$condorCMOptionDesc"
	echo "$cmNumberOptionDesc"
	echo "$expirationInHoursOptionDesc"
	exit 1
fi
set -e


expirationInHours=$9
if [ "x$expirationInHours" = "x" ]; then
	echo "No expirationInHours given. set it to $expirationInHoursDefault."
	expirationInHours=$expirationInHoursDefault;
else
	echo "expirationInHours set to $expirationInHours."
fi

expirationInMins=`echo whatever|awk '{print '$expirationInHours'*60}'`;
echo condor daemon will expire after $expirationInMins minutes.
echo "noOfCPUs=$noOfCPUs"
echo "cpuNoMultiplier=$cpuNoMultiplier"
echo "memoryRequired=$memoryRequired"
echo "memoryMultiplier=$memoryMultiplier"
echo "cmNumber is $cmNumber"
echo "central manager is $condorCM"
echo "sshDBTunnel=$sshDBTunnel"
echo "GLIDEIN_MAX_IDLE_HOURS=$GLIDEIN_MAX_IDLE_HOURS"
echo "Running on $machineHostname ..."

echo "condor will claim $cpuNoMultiplier\X as many cpus available."
#2012.3.29 -17Mb for each 1G because not all memory is available to the userspace condor daemon. i.e. a 32Gb machine has 530Mb memory unavailable.
echo "memoryRequired is $memoryRequired. noOfCPUs is $noOfCPUs."
memoryRequiredInMB=`echo $memoryRequired*$noOfCPUs*\(1024-17\)|bc`

memoryRequiredAfterMultiplying=`echo $memoryRequiredInMB*$memoryMultiplier|bc`
noOfCPUsAfterMultiplying=`echo $noOfCPUs*$cpuNoMultiplier|bc`

# condor folder to use
CONDOR_DIR=condor

echo "TOP_DIR is $TOP_DIR"

# this will contain logs/execute/spool
# 2011-11-26 stop attaching currentUnixTime to LOCAL_DIR. because it makes exporting CONDOR_CONFIG on master node complicated.
if test "$thisIsSlave" = "0"; then
	LOCAL_DIR=/tmp/condorM$currentUnixTime
else
	LOCAL_DIR=/tmp/condorS$currentUnixTime
fi

#clean up the condor conf folder
rm -rf $LOCAL_DIR/*


mkdir -p $LOCAL_DIR/execute
mkdir -p $LOCAL_DIR/log
mkdir -p $LOCAL_DIR/spool

# create an env file for easy sourcing
cat >$LOCAL_DIR/env.sh <<EOF
#!/bin/bash
export PATH=$TOP_DIR/$CONDOR_DIR/bin:$TOP_DIR/$CONDOR_DIR/sbin:$PATH
export CONDOR_CONFIG=$LOCAL_DIR/condor_config
EOF

. $LOCAL_DIR/env.sh

# fix the condor config file
cp $TOP_DIR/condor_config  $LOCAL_DIR/
perl -p -i -e "s:^RELEASE_DIR.*:RELEASE_DIR = $TOP_DIR/$CONDOR_DIR:" $LOCAL_DIR/condor_config
perl -p -i -e "s:^LOCAL_DIR( |\t).*:LOCAL_DIR = $LOCAL_DIR:" $LOCAL_DIR/condor_config
if test "$thisIsSlave" = "0"; then	#central manager won't have their local config file generated via script (otherwise, script will be run almost every mili-second)
	$TOP_DIR/makeCondorConfig.sh $noOfCPUs $memoryRequired $cpuNoMultiplier $memoryMultiplier $sshDBTunnel $GLIDEIN_MAX_IDLE_HOURS $condorCM $cmNumber >$LOCAL_DIR/condor_config.local
	#2012.10.14 condorCM has to be last because it's usually empty (=getting condorCM from $centralManagerFilename).
else
	perl -p -i -e "s:^LOCAL_CONFIG_FILE( |\t).*:LOCAL_CONFIG_FILE = $TOP_DIR/makeCondorConfig.sh $noOfCPUs $memoryRequired $cpuNoMultiplier $memoryMultiplier $sshDBTunnel $GLIDEIN_MAX_IDLE_HOURS $condorCM $cmNumber|:" $LOCAL_DIR/condor_config
	#2012.10.14 condorCM has to be last because it's usually empty (=getting condorCM from $centralManagerFilename).
fi


exec condor_master -f -r $expirationInMins

#-f: Causes the daemon to start up in the foreground. Instead of forking, the daemon runs in the foreground.
#-r MINUTES: Causes the daemon to set a timer, upon expiration of which, it sends itself a SIGTERM for graceful shutdown.

# 2012.4.17 delete everything in the local config folder
# 2013.06.16 set cleanup as a trap because condor_master is run with "exec", replacing parental shell process and any command after that will be ignored.
# 2013.06.16 it doesn't work to insert this trap statement in front of "exec ..."
#trap "rm $LOCAL_DIR -rf; exit" 1 9 15
rm $LOCAL_DIR -rf
