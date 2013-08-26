#!/bin/bash

shellDir=`dirname $0`
source $shellDir/common.sh

if test $# -lt 1 ; then
	echo "  $0 [noOfCPUs] [memoryRequired] [cpuNoMultiplier] [memoryMultiplier] [sshDBTunnel] [GLIDEIN_MAX_IDLE_HOURS] [condorCM] [cmNumber]"
	echo ""
	echo "Note:"
	echo "$noOfCPUsOptionDesc"
	echo $cpuNoMultiplierOptionDesc 
	echo $memoryRequiredOptionDesc
	echo $memoryMultiplierOptiondesc
	echo $sshDBTunnelOptionDesc
	echo $GLIDEIN_MAX_IDLE_HOURSOptionDesc
	echo $condorCMOptionDesc
	echo $cmNumberOptionDesc
	exit 1
fi
set -e


#echo "condor will claim $cpuNoMultiplier\X as many cpus available."
#2012.3.29 -17Mb for each 1G because not all memory is available to the userspace condor daemon. i.e. a 32Gb machine has 530Mb memory unavailable.
#deduce from /proc/meminfo
memoryAvailableInKB=`cat /proc/meminfo |head -n 1|awk -F ' ' '{print $2}'`
memoryAvailableInMB=`echo $memoryAvailableInKB/\(1024+1\)|bc`
#what user requested
memoryRequiredInMB=`echo $memoryRequired*$noOfCPUs*\(1024-27\)|bc`

memoryRequiredAfterMultiplying=`echo $memoryRequiredInMB*$memoryMultiplier|bc`

#2012.7.23 upper bound for memory advertised on a machine
#if test $memoryRequiredAfterMultiplying -gt $memoryAvailableInMB; then
#fi
realisticMemoryRequest=`python -c "print min($memoryAvailableInMB, $memoryRequiredAfterMultiplying)"`
noOfCPUsAfterMultiplying=`echo $noOfCPUs*$cpuNoMultiplier|bc`

# condor folder to use
CONDOR=condor

# this will contain logs/execute/spool
# 2012.7.31 remove . from the currentUnixTime, or condor_startd name

localCondorConfigFile=/tmp/condor$currentUnixTime.condor_config.local
#2012.5.8 delete it first if it exists
if test -r $localCondorConfigFile; then
	rm $localCondorConfigFile >& /dev/null
fi
# provide a backbone local config file
cp $TOP_DIR/condor_config.local $localCondorConfigFile

#2012.2.27 setup proper memory

# 2012.7.23, upper bound for memory but not successful. do it through shell (above)
#echo "candidateMemoryList = \$(DETECTED_MEMORY), $memoryRequiredAfterMultiplying" >>$localCondorConfigFile
#echo "realisticMemoryRequest = debug(stringListMin(\$(candidateMemoryList)))" >>$localCondorConfigFile #can't make it work

echo "SLOT_TYPE_1 = cpus=100%, memory=$realisticMemoryRequest " >>$localCondorConfigFile
#2011.12.13 report the number of cpus after multiplying
echo "NUM_CPUS=$noOfCPUsAfterMultiplying" >>$localCondorConfigFile
echo "CONDOR_HOST=$CONDOR_HOST" >>$localCondorConfigFile

#noOfGrepLines=`ps -ef OT|grep dl324b-1.cmb.usc.edu:5432|wc -l`
#if test "$noOfGrepLines" = "2"; then	#sshTunnel is there. grep process will show up in ps -ef OT.
#	echo "sshDBTunnel=1" >>$localCondorConfigFile
#else
#	echo "sshDBTunnel=0" >>$localCondorConfigFile
#	#2012.4.16 add sshDBTunnel classAd for this machine
#	#echo "sshDBTunnel=$sshDBTunnel" >>$localCondorConfigFile
#	#ssh -N -L 5432:dl324b-1.cmb.usc.edu:5432 polyacti@login3 & 
#	#tunnelProcessID=0
#fi

#echo "STARTD_ATTRS = sshDBTunnel \$(STARTD_ATTRS)" >>$localCondorConfigFile

# 2012.3.6 kill jobs immediately after preempt (when it's near the condor_master expiration time)
#echo "PREEMPT = (CurrentTime - DaemonStartTime) > ($expirationInHours*\$(HOUR)-10*\$(MINUTE))" >>$localCondorConfigFile
#echo "WANT_VACATE = FALSE" >>$localCondorConfigFile
#echo "KILL = TRUE # No longer matters" >>$localCondorConfigFile
#echo "KILL = (\$(CurrentTime) - \$(DaemonStartTime)) > $expirationInHours*\$(HOUR)" >>$LOCAL_DIR/condor_config.local

if test "$thisIsSlave" = "1"
then
	#differentiate between different STARTD processes on the same machine
	machineName=`hostname -f`
	# 2012.7.31 "." is no longer allowed to be part of STARTD_NAME in condor 7.8. but "_" or "\" is ok.
	echo "MASTER_NAME=$machineName\_$currentUnixTime" >>$localCondorConfigFile
	echo "STARTD_NAME=$machineName\_$currentUnixTime" >>$localCondorConfigFile
	
	#2012.10.9 die after no jobs for 3 hours
	# How long will it wait in an unclaimed state before exiting (in seconds)
	GLIDEIN_MAX_IDLE_SECS=`echo $GLIDEIN_MAX_IDLE_HOURS*60*60|bc`
	echo "STARTD_NOCLAIM_SHUTDOWN = $GLIDEIN_MAX_IDLE_SECS" >> $localCondorConfigFile
	
fi
echo "#FILESYSTEM_DOMAIN=$CONDOR_HOST" >>$localCondorConfigFile
echo "FILESYSTEM_DOMAIN=\$(FULL_HOSTNAME)$currentUnixTime" >>$localCondorConfigFile
echo "DAEMON_LIST=$CONDOR_DAEMON_LIST" >>$localCondorConfigFile


#2012.6.11 periodically check whether ssh DB tunnel is there
#echo "checkSSHDBTunnel = /u/home/eeskin/polyacti/script/shell/condor_launch/checkSSHDBTunnel.sh" >> $localCondorConfigFile
#echo "STARTD_CRON_JOBLIST = \$(STARTD_CRON_JOBLIST) checkSSHDBTunnel" >> $localCondorConfigFile
#echo "STARTD_CRON_checkSSHDBTunnel_EXECUTABLE = \$(checkSSHDBTunnel)" >> $localCondorConfigFile
#echo "STARTD_CRON_checkSSHDBTunnel_PERIOD = 120" >> $localCondorConfigFile

#echo "ALL_DEBUG = D_ALL" >> $localCondorConfigFile
#echo "STARTD_DEBUG=D_FULLDEBUG" >> $localCondorConfigFile
cat $localCondorConfigFile
if test -r $localCondorConfigFile; then
	echo rm $localCondorConfigFile >& /dev/null
fi
