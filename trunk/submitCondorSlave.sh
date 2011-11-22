#!/bin/sh

noOfCpusPerNodeDefault=8
noOfCondorSlavesDefault=100

if test $# -lt 1 ; then
	echo "  $0 masterHost [noOfCpusPerNode] [noOfCondorSlaves]"
	echo ""
	echo "Note:"
	echo "	#. masterHost is the node where the master is."
	echo "	#. noOfCpusPerNode is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is $noOfCpusPerNodeDefault."
	echo "	#. noOfCondorSlaves is the max number of condor slaves running/in SGE queue. Default is $noOfCondorSlavesDefault. The script goes into sleep and checks periodically to see whether it needs to submit another slave job."
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

shellRepositoryPath=`dirname $0`
noOfCondorJobs=`qstat -u polyacti|grep condor|wc -l|awk -F ' ' '{print $1}'`
echo $noOfCondorJobs condor jobs now.

while test $noOfCondorJobs -le $noOfCondorSlaves
do
	currentUnixTime=`echo "import time; print time.time()"|python`
	jobscriptFileName=/tmp/condorS.$currentUnixTime.sh
	echo job script: $jobscriptFileName
	cat >$jobscriptFileName <<EOF
#!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -o \$JOB_NAME.joblog.\$JOB_ID
#$ -j y
#$ -l h_rt=23:59:00
#$ -pe shared* $noOfCpusPerNode
#$ -V
source ~/.bash_profile
$shellRepositoryPath/condor_launch/launch.sh 24 $masterHost
EOF
	qsub $jobscriptFileName
	#rm $jobscriptFileName
	#$ -q eeskin_idre.q
	sleep 10
	noOfCondorJobs=`qstat -u polyacti|grep condor|wc -l|awk -F ' ' '{print $1}'`
	echo $noOfCondorJobs condor jobs now.
done
