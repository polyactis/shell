#!/bin/sh

noOfCpusPerNodeDefault=8

if test $# -lt 1 ; then
	echo "  $0 noOfHours [noOfCpusPerNode]"
	echo ""
	echo "Note:"
	echo "	#. noOfHours is the number of hours the master node requests. Note: highp is added, so it could as high as 336 (two weeks) if no cluster shutdown is in sight."
	echo "	#. noOfCpusPerNode is passed to SGE on how many cpus to occupy on each node. But condor takes all cpus on each node. Default is $noOfCpusPerNodeDefault."
	exit 1
fi
noOfHours=$1
noOfCpusPerNode=$2
if [ -z $noOfCpusPerNode ]
then
	noOfCpusPerNode=$noOfCpusPerNodeDefault
fi
shellRepositoryPath=`dirname $0`
currentUnixTime=`echo "import time; print time.time()"|python`
jobscriptFileName=/tmp/condorM.$currentUnixTime.sh
echo job script: $jobscriptFileName
cat >$jobscriptFileName <<EOF
#!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -o ~/qjob_output/\$JOB_NAME.joblog.\$JOB_ID
#$ -j y
#$ -l h_rt=$noOfHours:00:00,highp
#$ -pe shared* $noOfCpusPerNode
#$ -V
source ~/.bash_profile
$shellRepositoryPath/condor_launch/launch.sh $noOfHours $noOfCpusPerNode
EOF
qsub $jobscriptFileName
#rm $jobscriptFileName
#$ -q eeskin_idre.q
