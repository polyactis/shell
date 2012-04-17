#!/bin/sh

noOfCpusPerNodeDefault=8
memoryRequiredDefault=8

cpuNoMultiplierDefault=1
memoryMultiplierDefault=1

if test $# -lt 1 ; then
	echo "  $0 noOfHours [noOfCpusPerNode] [memoryRequired] [cpuNoMultiplier] [memoryMultiplier]"
	echo ""
	echo "Note:"
	echo "	#. noOfHours is the number of hours the master node requests. Note: highp is added, so it could as high as 336 (two weeks) if no cluster shutdown is in sight."
	echo "	#. noOfCpusPerNode is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is $noOfCpusPerNodeDefault."
	echo "	#. memoryRequired is the amount of memory needed for this job in unit of Giga-byte. Default is $memoryRequiredDefault."
	echo "	#. cpuNoMultiplier is to let condor claim it has noOfCpusPerNode*cpuNoMultiplier cpus. Default is $cpuNoMultiplierDefault."
	echo "	#. memoryMultiplier is to let condor claim it has memoryRequired*memoryMultiplier memory. Default is $memoryMultiplierDefault."
	exit 1
fi
noOfHours=$1
noOfCondorHours=`echo whatever|awk '{print '$noOfHours'-1}'`
echo "qsub job will live for $noOfHours hours."
echo "condor will live for $noOfCondorHours.8 hours."

noOfCpusPerNode=$2
if [ -z $noOfCpusPerNode ]
then
	noOfCpusPerNode=$noOfCpusPerNodeDefault
fi

memoryRequired=$3
if [ -z $memoryRequired ]
then
	memoryRequired=$memoryRequiredDefault
fi
memoryRequiredInString=$memoryRequired\G

cpuNoMultiplier=$4
if [ -z $cpuNoMultiplier ]
then
	cpuNoMultiplier=$cpuNoMultiplierDefault
fi

memoryMultiplier=$5
if [ -z $memoryMultiplier ]
then
	memoryMultiplier=$memoryMultiplierDefault
fi

echo "condor will claim $noOfCpusPerNode X $cpuNoMultiplier cpus available."
echo "condor will claim $memoryRequired X $memoryMultiplier\Gb memory."

shellRepositoryPath=`dirname $0`
currentUnixTime=`echo "import time; print time.time()"|python`
jobscriptFileName=/tmp/condorM.$currentUnixTime.sh
echo job script: $jobscriptFileName
cat >$jobscriptFileName <<EOF
#!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -o ./qjob_output/\$JOB_NAME.joblog.\$JOB_ID
#$ -j y
#$ -l h_data=$memoryRequiredInString
#$ -l h_rt=$noOfHours:00:00,highp
#$ -pe shared* $noOfCpusPerNode
#$ -V
source ~/.bash_profile
#exit 0.2 hour earlier than the job exit
#2012.2.28 tunnel for the vervetdb
~/script/shell/sshTunnelForDB.sh
$shellRepositoryPath/condor_launch/launch.sh $noOfCondorHours.8 $noOfCpusPerNode $memoryRequired $cpuNoMultiplier $memoryMultiplier
EOF
qsub $jobscriptFileName
#rm $jobscriptFileName
#$ -q eeskin_idre.q
