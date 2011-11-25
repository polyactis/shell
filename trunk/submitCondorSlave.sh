#!/bin/sh

noOfCpusPerNodeDefault=8
noOfCondorSlavesDefault=100
noOfSleepSecondsDefault=1800
if test $# -lt 1 ; then
	echo "  $0 masterHost [noOfCpusPerNode] [noOfCondorSlaves] [noOfSleepSeconds]"
	echo ""
	echo "Note:"
	echo "	#. masterHost is the node where the master is."
	echo "	#. noOfCpusPerNode is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is $noOfCpusPerNodeDefault."
	echo "	#. noOfCondorSlaves is the max number of condor slaves running/in SGE queue. Default is $noOfCondorSlavesDefault. The script goes into sleep and checks periodically to see whether it needs to submit another slave job."
	echo "	#. noOfSleepSeconds is the number of seconds for this script to sleep before it submits another condor slave job. Default is $noOfSleepSecondsDefault."
	exit 1
fi
masterHost=$1
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
noOfSleepSeconds=$4
if [ -z $noOfSleepSeconds ]
then
	noOfSleepSeconds=$noOfSleepSecondsDefault
fi

shellRepositoryPath=`dirname $0`
noOfCondorJobs=`qstat -u polyacti|grep condor|wc -l|awk -F ' ' '{print $1}'`
echo $noOfCondorJobs condor jobs now, to reach $noOfCondorSlaves.

while test 1 -le 2
do
	if test $noOfCondorJobs -le $noOfCondorSlaves
	then
		echo "$noOfCpusPerNode cpus for each condor slave"
		echo "Master is $masterHost"
		currentUnixTime=`echo "import time; print time.time()"|python`
		jobscriptFileName=/tmp/condorS.$currentUnixTime.sh
		echo job script: $jobscriptFileName
		cat >$jobscriptFileName <<EOF
#!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -o ~/qjob_output/\$JOB_NAME.joblog.\$JOB_ID
#$ -j y
#$ -l h_rt=23:59:00
#$ -pe shared* $noOfCpusPerNode
#$ -V
source ~/.bash_profile
$shellRepositoryPath/condor_launch/launch.sh 24 $noOfCpusPerNode $masterHost
EOF
		qsub $jobscriptFileName
		#rm $jobscriptFileName
		#$ -q eeskin_idre.q
	fi
	echo "sleep now for $noOfSleepSeconds seconds"
	sleep $noOfSleepSeconds
	noOfCondorJobs=`qstat -u polyacti|grep condor|wc -l|awk -F ' ' '{print $1}'`
	echo $noOfCondorJobs condor jobs now, to reach $noOfCondorSlaves.
done
