#!/bin/sh

noOfCpusPerNodeDefault=8
noOfCondorSlavesDefault=100
noOfHoursToLiveDefault=24
noOfSleepSecondsDefault=1800
memoryRequiredDefault=8
cpuNoMultiplierDefault=1
memoryMultiplierDefault=1
sshDBTunnelDefault=0
if test $# -lt 1 ; then
	echo "  $0 masterHost [noOfCpusPerNode] [noOfCondorSlaves] [noOfHoursToLive] [noOfSleepSeconds] [memoryRequired] [cpuNoMultiplier] [memoryMultiplier] [sshDBTunnel] "
	echo ""
	echo "Note:"
	echo "	#. masterHost is the node where the master is. If masterHost is -, then itself will become central manger. If it equals =, then it will try to get central manager hostname from ~/condor_central_manager.txt or become central manger itself if the latter is empty. This script absorbs submitCondorMaster.sh's functionality. The latter is not longer maintained. "
	echo "	#. noOfCpusPerNode is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is $noOfCpusPerNodeDefault."
	echo "	#. noOfCondorSlaves is the max number of condor slaves running/in SGE queue. Default is $noOfCondorSlavesDefault. The script goes into sleep and checks periodically to see whether it needs to submit another slave job."
	echo "	#. noOfHoursToLive is the number of hours for the slave to remain alive. Default is $noOfHoursToLiveDefault. If it's more than 24, argument highp will be added, which limits jobs to 2 queues, eeskin_idre.q and eeskin_pod.q."
	echo "	#. noOfSleepSeconds is the number of seconds for this script to sleep before it submits another condor slave job. Default is $noOfSleepSecondsDefault."
	echo "	#. memoryRequired is the amount of memory needed for this job in unit of Giga-byte. Default is $memoryRequiredDefault."
	echo "	#. cpuNoMultiplier is to let condor claim it has noOfCpusPerNode*cpuNoMultiplier cpus. Default is $cpuNoMultiplierDefault."
	echo "	#. memoryMultiplier is to let condor claim it has memoryRequired*memoryMultiplier memory. Default is $memoryMultiplierDefault."
	exit 1
fi
masterHost=$1
thisIsSlave=1
#2012.4.16 set masterHost to nothing if it is "=". This will cause launch.sh to read from ~/condor_central_manager.txt to get the central manager or become central manager itself if the latter file is empty.
if test "$masterHost" = "="; then
	masterHost=""
fi
if test "$masterHost" = "-"; then
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

countCondorSJobs () {
	echo `qstat -u polyacti|grep condor|wc -l|awk -F ' ' '{print $1}'`
}
shellRepositoryPath=`dirname $0`
noOfCondorJobs=`countCondorSJobs`
echo "qsub job will live for $noOfHoursToLive hours."
echo "condor will live for $noOfCondorHours.8 hours."
echo "condor will claim $memoryRequired X $memoryMultiplier\Gb memory."
echo $noOfCondorJobs condor jobs now, to reach $noOfCondorSlaves.

if test "$thisIsSlave" = "0"; then
	scriptFnamePrefix=/tmp/condorM
else
	scriptFnamePrefix=/tmp/condorS
fi

while test 1 -le 2
do

	if test $noOfCondorJobs -le $noOfCondorSlaves
	then
		echo "$noOfCpusPerNode cpus for each condor slave."
		echo "Master is $masterHost."
		echo "qsub job will live for $noOfHoursToLive hours."
		echo "condor will live for $noOfCondorHours.8 hours."
		echo "condor will claim $noOfCpusPerNode X$cpuNoMultiplier cpus available."
		echo "condor will claim $memoryRequired X$memoryMultiplier Gb memory."
		echo "sshDBTunnel=$sshDBTunnel."
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
if test "\$sshDBTunnel" = "1"; then
	ssh -N -L 5432:dl324b-1.cmb.usc.edu:5432 polyacti@login3 & 
	tunnelProcessID=\$!
else
	tunnelProcessID=0
fi

echo tunnelProcessID is \$tunnelProcessID

~/script/shell/condor_launch/launch.sh $noOfCondorHours.8 $noOfCpusPerNode $memoryRequired $cpuNoMultiplier $memoryMultiplier $sshDBTunnel $masterHost

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
