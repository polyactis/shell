#!/bin/sh

clusterUsernameDefault=polyacti
noOfCondorSlavesDefault=100
noOfSleepSecondsDefault=180

if test $# -lt 1 ; then
	echo "  $0 masterHost [noOfCondorSlaves] [noOfSleepSeconds] [clusterUsername]"
	echo ""
	echo "Note:"
	echo "	#. clusterUsername is the user who submits these condor jobs. Default is $clusterUsernameDefault."
	echo "	#. masterHost is the node where the master is. If it equals =, it will try to get central manager hostname from ~/condor_central_manager.txt or become central manger itself if the latter is empty."
	echo "	#. noOfCondorSlaves is the max number of condor slaves running/in SGE queue. Default is $noOfCondorSlavesDefault. The script goes into sleep and checks periodically to see whether it needs to submit another slave job."
	echo "	#. noOfSleepSeconds is the number of seconds for this script to sleep before it submits another condor slave job. Default is $noOfSleepSecondsDefault."
	exit 1
fi
masterHost=$1

noOfCondorSlaves=$2
if [ -z $noOfCondorSlaves ]
then
	noOfCondorSlaves=$noOfCondorSlavesDefault
fi
noOfSleepSeconds=$3
if [ -z $noOfSleepSeconds ]
then
	noOfSleepSeconds=$noOfSleepSecondsDefault
fi

clusterUsername=$4
if [ -z $clusterUsername ]
then
	clusterUsername=$clusterUsernameDefault
fi
echo clusterUsername is $clusterUsername.

countCondorSJobs () {
	echo `qstat -u polyacti|grep condor|wc -l|awk -F ' ' '{print $1}'`
}
findOneCondorJobNode() {
	echo `qstat -u $clusterUsername|grep condor|head -n 2|tail -n 1|awk -F ' ' '{print $8}'|awk -F '@' '{print $2}'`
}
shellRepositoryPath=`dirname $0`
noOfCondorJobs=`countCondorSJobs`
echo $noOfCondorJobs condor jobs now, reduce to $noOfCondorSlaves.

while test $noOfCondorSlaves -le $noOfCondorJobs
do
	jobNode=`findOneCondorJobNode`
	echo jobNode is $jobNode.
	if test "$jobNode" != "$masterHost"
	then
		ssh $clusterUsername@$jobNode "~/script/shell/kill_jobs.sh condor 15 1"
		echo "condor on $jobNode is killed"
		#for i in `ps -ef OT|grep polyacti|grep condor|awk -F ' ' '{print $2}'`; do echo $i ; done
	else
		echo "$jobNode is the master node. No kill"
	fi

	echo "sleep now for $noOfSleepSeconds seconds"
	sleep $noOfSleepSeconds
	noOfCondorJobs=`countCondorSJobs`
	echo $noOfCondorJobs condor jobs now, reduce to  $noOfCondorSlaves.
done
