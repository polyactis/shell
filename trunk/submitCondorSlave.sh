#!/bin/sh

noOfCpusPerNodeDefault=8
noOfCondorSlavesDefault=100
noOfHoursToLiveDefault=24
noOfSleepSecondsDefault=1800
memoryRequiredDefault=8
cpuNoMultiplierDefault=1
memoryMultiplierDefault=1
sshDBTunnelDefault=0
GLIDEIN_MAX_IDLE_HOURS_DEFAULT=3
targetHostDefault=crocea.mednet.ucla.edu
targetPortDefault=5432

if test $# -lt 1 ; then
	echo "  $0 condorHost [noOfCpusPerNode] [noOfCondorSlaves] [noOfHoursToLive] [noOfSleepSeconds] [memoryRequired] [cpuNoMultiplier] [memoryMultiplier] [sshDBTunnel]  [GLIDEIN_MAX_IDLE_HOURS] [dbHost] [dbPort]"
	echo ""
	echo "Note:"
	echo "	#. condorHost is the node where the master is. If condorHost is -, then itself will become central manger. If it equals =, then it will try to get central manager hostname from ~/condor_central_manager.txt or become central manger itself if the latter is empty. This script absorbs submitCondorMaster.sh's functionality. The latter is not longer maintained. "
	echo "	#. noOfCpusPerNode is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is $noOfCpusPerNodeDefault."
	echo "	#. noOfCondorSlaves is the max number of condor slaves running/in SGE queue. Default is $noOfCondorSlavesDefault. The script goes into sleep and checks periodically to see whether it needs to submit another slave job."
	echo "	#. noOfHoursToLive is the number of hours for the slave to remain alive. Default is $noOfHoursToLiveDefault. If it's more than 24, argument highp will be added, which limits jobs to 2 queues, eeskin_idre.q and eeskin_pod.q."
	echo "	#. noOfSleepSeconds is the number of seconds for this script to sleep before it submits another condor slave job. Default is $noOfSleepSecondsDefault."
	echo "	#. memoryRequired is the amount of memory needed for this job in unit of Giga-byte. Default is $memoryRequiredDefault."
	echo "	#. cpuNoMultiplier is to let condor claim it has noOfCpusPerNode*cpuNoMultiplier cpus. Default is $cpuNoMultiplierDefault."
	echo "	#. memoryMultiplier is to let condor claim it has memoryRequired*memoryMultiplier memory. Default is $memoryMultiplierDefault."
	echo "	#. GLIDEIN_MAX_IDLE_HOURS is the number of idling hours after which condor slave (not master) exits. Default is $GLIDEIN_MAX_IDLE_HOURS_DEFAULT ."
	echo "	#. dbHost is the hostname for the database server (will be ssh tunnelled). Default is $targetHostDefault."
	echo "	#. dbPort is the database daemon port on the dbHost. Default is $targetPortDefault."
	echo
	echo "Examples:"
	echo "	# submit short/24-hr condor slaves, 1 cpu per node, max no. of slaves =490, cluster job walltime =24hrs, no ssh tunnel for, GLIDEIN_MAX_IDLE_HOURS is 0.5 (half an hour) "
	echo "	$0 = 1 490 24 3 4 1 2 0 0.5"
	echo
	echo "	# submit long-hr (300-hr) condor slaves with ssh DB tunnel. 3 cpus per slave. GLIDEIN_MAX_IDLE_HOURS=300"
	echo "	$0 = 3 35 300 5 4 1 2 1 300"
	echo
	exit 1
fi
condorHost=$1
thisIsSlave=1
#2012.4.16 set condorHost to nothing if it is "=". This will cause launch.sh to read from ~/condor_central_manager.txt to get the central manager or become central manager itself if the latter file is empty.
if test "$condorHost" = "="; then
	condorHost=""
fi
if test "$condorHost" = "-"; then
	thisIsSlave=0
fi

noOfCpusPerNode=$2
if [ -z $noOfCpusPerNode ]
then
	noOfCpusPerNode=$noOfCpusPerNodeDefault
fi
noOfCondorSlaves=$3
if [ -z $noOfCondorSlaves ]
then
	noOfCondorSlaves=$noOfCondorSlavesDefault
fi
noOfHoursToLive=$4
if [ -z $noOfHoursToLive ]
then
	noOfHoursToLive=$noOfHoursToLiveDefault
fi
noOfCondorHours=`echo whatever|awk '{print '$noOfHoursToLive'-1}'`
noOfSleepSeconds=$5
if [ -z $noOfSleepSeconds ]
then
	noOfSleepSeconds=$noOfSleepSecondsDefault
fi

memoryRequired=$6
if [ -z $memoryRequired ]
then
	memoryRequired=$memoryRequiredDefault
fi
memoryRequiredInString=$memoryRequired\G

cpuNoMultiplier=$7
if [ -z $cpuNoMultiplier ]
then
	cpuNoMultiplier=$cpuNoMultiplierDefault
fi

memoryMultiplier=$8
if [ -z $memoryMultiplier ]
then
	memoryMultiplier=$memoryMultiplierDefault
fi

#2012.4.16
sshDBTunnel=$9
if [ -z $sshDBTunnel ]
then
	sshDBTunnel=$sshDBTunnelDefault
fi

#2012.10.12 shell's position variable is 0 to 9. no more.
shift
GLIDEIN_MAX_IDLE_HOURS=$9
if [ -z $GLIDEIN_MAX_IDLE_HOURS ]
then
	GLIDEIN_MAX_IDLE_HOURS=$GLIDEIN_MAX_IDLE_HOURS_DEFAULT
fi

shift
targetHost=$9
if [ -z $targetHost ]
then
	targetHost=$targetHostDefault
fi

shift
targetPort=$9
if [ -z $targetPort ]
then
	targetPort=$targetPortDefault
fi

slaveScriptFnamePrefix='jobS'
countCondorSJobs () {
	echo `qstat -u polyacti|grep $slaveScriptFnamePrefix|wc -l|awk -F ' ' '{print $1}'`
}
shellRepositoryPath=`dirname $0`
reportArguments () {
	echo "$noOfCpusPerNode cpus for each condor slave."
	echo "Master is $condorHost ."
	echo "qsub job will live for $noOfHoursToLive hours."
	echo "condor will live for $noOfCondorHours.8 hours."
	echo "condor will claim $noOfCpusPerNode X$cpuNoMultiplier cpus available."
	echo "condor will claim $memoryRequired X$memoryMultiplier Gb memory."
	echo "sshDBTunnel=$sshDBTunnel."
	echo "GLIDEIN_MAX_IDLE_HOURS=$GLIDEIN_MAX_IDLE_HOURS."
	noOfCondorJobs=`countCondorSJobs`
	echo $noOfCondorJobs condor jobs now, to reach $noOfCondorSlaves.
}

reportArguments

if test "$thisIsSlave" = "0"; then
	scriptFnamePrefix=/tmp/jobM
else
	scriptFnamePrefix=/tmp/$slaveScriptFnamePrefix
fi
#2012.10.25 changed
#targetHost=dl324b-1.cmb.usc.edu
#targetHost=crocea.mednet.ucla.edu
#targetPort=5432
while test 1 -le 2
do

	if test $noOfCondorJobs -le $noOfCondorSlaves
	then
		reportArguments
		currentUnixTime=`echo "import time; print time.time()"|python`
		jobscriptFileName=$scriptFnamePrefix.$currentUnixTime.sh
		echo job script: $jobscriptFileName
		cat >$jobscriptFileName <<EOF
#!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -o  ./qjob_output/\$JOB_NAME.joblog.\$JOB_ID
#$ -j y
#$ -l h_data=$memoryRequiredInString
#$ -l h_rt=$noOfHoursToLive:00:00
#$ -V
EOF
		if test $noOfCpusPerNode -gt 1
		then
			#2012.2.28 add "-pe shared* ..." if more than one cpu is needed on one node.
			cat >>$jobscriptFileName <<EOF
#$ -pe shared* $noOfCpusPerNode
EOF
		fi
		if test $noOfHoursToLive -gt 24
		then
			#2011.12.14 add highp if this would last >24 hours
			cat >>$jobscriptFileName <<EOF
#$ -l highp
EOF
		fi
		cat >>$jobscriptFileName <<EOF
source ~/.bash_profile
#exit 0.2 hour earlier than the job exit
#2012.2.28 tunnel for the vervetdb. #2012.4.16 only when sshDBTunnel=1. pass the variable into the sge script first.
sshDBTunnel=$sshDBTunnel
#2012.6.8 a script to check whether ssh tunnel has already been in place on this node. If yes, don't run ssh tunnel.
if test "\$sshDBTunnel" = "1"; then
	noOfGrepLines=\`ps -ef OT|grep $targetHost:$targetPort|wc -l\`
	if test "\$noOfGrepLines" = "1"; then	#not there. grep process will show up in ps -ef OT.
		ssh -N -L 5432:$targetHost:$targetPort polyacti@login4 & 
		tunnelProcessID=\$!
	else
		tunnelProcessID=0
	fi
else
	tunnelProcessID=0
fi

echo tunnelProcessID is \$tunnelProcessID

~/script/shell/condor_launch/launch.sh $noOfCondorHours.8 $noOfCpusPerNode $memoryRequired $cpuNoMultiplier $memoryMultiplier $sshDBTunnel $GLIDEIN_MAX_IDLE_HOURS $condorHost
#2012.10.14 condorHost has to be last because it's usually empty (=getting condorHost from $centralManagerFilename).

if test \$tunnelProcessID -gt 0; then
	kill -term \$tunnelProcessID
fi
EOF
		qsub $jobscriptFileName
		#rm $jobscriptFileName
		#$ -q eeskin_idre.q
	fi
	echo "sleep now for $noOfSleepSeconds seconds"
	sleep $noOfSleepSeconds
	noOfCondorJobs=`countCondorSJobs`
	echo $noOfCondorJobs condor jobs now, to reach $noOfCondorSlaves.
done
