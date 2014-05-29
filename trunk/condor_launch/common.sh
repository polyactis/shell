

cpuNoMultiplierDefault=1
memoryRequiredDefault=10
memoryMultiplierDefault=1
sshDBTunnelDefault=0
GLIDEIN_MAX_IDLE_HOURS_DEFAULT=3
condorCMDefault==
cmNumberDefault=1

noOfCPUsOptionDesc="	#. noOfCPUs is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is what condor detects."
cpuNoMultiplierOptionDesc="	#. cpuNoMultiplier is to let condor claim it has noOfCPUs*cpuNoMultiplier cpus. Default is $cpuNoMultiplierDefault."
memoryRequiredOptionDesc="	#. memoryRequired is the amount of memory needed for this job in unit of Giga-byte. Default is $memoryRequiredDefault. Final memory that condor will broadcast is memoryRequired*noOfCPUs."
memoryMultiplierOptiondesc="	#. memoryMultiplier is to let condor claim it has memoryRequired*memoryMultiplier memory. Default is $memoryMultiplierDefault."
sshDBTunnelOptionDesc="	#. sshDBTunnel is the variable added to the machine classAd. If =1, means this machine has a ssh tunnel to access psql db on dl324b-1. Otherwise (=0 or non-1), it does not. Make sure run ~/script/shell/sshTunnelForDB.sh on =1 machines. Default value is $sshDBTunnelDefault"
GLIDEIN_MAX_IDLE_HOURSOptionDesc="	#. GLIDEIN_MAX_IDLE_HOURS is the number of idling hours after which condor slave (not master) exits. Default is $GLIDEIN_MAX_IDLE_HOURS_DEFAULT ."
condorCMOptionDesc="	#. condorCM is the condor central manager. If it is "-", hostname of the machine itself is taken as central manager. If it is "=", it will try to read the central manager from ~/condor_central_manager.txt or become central manager on its own if the latter file is empty or non-existent. Default is $condorCMDefault"
cmNumberOptionDesc="	#. cmNumber determines which central manager to use in case ~/condor_central_manager.txt contains multiple machine names in it (one per line). Default is $cmNumberDefault. If the number specified is more than the number of hosts in ~/condor_central_manager.txt, the last machine would be used"

noOfCPUs=$1
memoryRequired=$2
cpuNoMultiplier=$3
memoryMultiplier=$4
sshDBTunnel=$5
GLIDEIN_MAX_IDLE_HOURS=$6
condorCM=$7	#2012.10.14 condorCM has to be last because it's usually empty (=getting condorCM from $centralManagerFilename).
cmNumber=$8



if [ "x$noOfCPUs" = "x" ]; then
	#echo "No noOfCPUs given. set it to \$(DETECTED_CORES)"
	noOfCPUs="\$(DETECTED_CORES)";
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

if [ -z $GLIDEIN_MAX_IDLE_HOURS ]
then
	GLIDEIN_MAX_IDLE_HOURS=$GLIDEIN_MAX_IDLE_HOURS_DEFAULT
fi

if [ -z $condorCM ]
then
	condorCM=$condorCMDefault
fi

if [ -z $cmNumber ]
then
	cmNumber=$cmNumberDefault
fi

#find the central manager
centralManagerFilename=~/condor_central_manager.txt
if test -f $centralManagerFilename; then
	centralManagerHostname=`head -n $cmNumber $centralManagerFilename|tail -n 1`
else
	centralManagerHostname=""
fi
echo "# condorCM is $condorCM"
echo "# centralManagerHostname is $centralManagerHostname."
#2014.05.08 shorten the hostname
machineHostname=`hostname -f|cut -f12-`
thisIsSlave=0
if [ "x$condorCM" = "x-" ]; then
	#echo "assuming I'm the new master!"
	CONDOR_HOST=$machineHostname
	CONDOR_DAEMON_LIST="MASTER, COLLECTOR, NEGOTIATOR, STARTD, SCHEDD"
	thisIsSlave=0
elif [ "x$condorCM" = "x=" ]; then
	if test -f $centralManagerFilename; then
		CONDOR_HOST=$centralManagerHostname
	fi
	if [ "x$CONDOR_HOST" = "x" ]; then
		#echo "No master host fetched - assuming I'm the new master!"
		CONDOR_HOST=$machineHostname
		CONDOR_DAEMON_LIST="MASTER, COLLECTOR, NEGOTIATOR, STARTD, SCHEDD"
		thisIsSlave=0
		#echo "When registering workers, please specify $CONDOR_HOST as the central manager"
	else
		#echo "Starting worker for the master at $condorCM"
		#CONDOR_HOST=$condorCM
		CONDOR_DAEMON_LIST="MASTER, STARTD"
		thisIsSlave=1
	fi
else
	#echo "Starting worker for the master at $condorCM"
	CONDOR_HOST=$condorCM
	CONDOR_DAEMON_LIST="MASTER, STARTD"
	thisIsSlave=1
fi
echo "# CONDOR_HOST is $CONDOR_HOST"
# 2012.7.31 remove . from the currentUnixTime, or condor_startd name
currentUnixTime=`echo "import time; print str(time.time()).replace('.', '_')"|python`

TOP_DIR=`dirname $0`
TOP_DIR=`cd $TOP_DIR && pwd`

#2012.8.5 set the noOfCPUs to zero if the machineHostname=centralManagerHostname
if test -n "$machineHostname" && test "$machineHostname" = "$centralManagerHostname" ; then
	echo "# machineHostname ($machineHostname) is same as centralManagerHostname ($centralManagerHostname), set noOfCPUs to 0."
	noOfCPUs=0
fi

echo "#noOfCPUs set to $noOfCPUs."
