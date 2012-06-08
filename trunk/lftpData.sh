#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -o $JOB_NAME.joblog.$JOB_ID
#$ -j y
#$ -l time=200:00:00
#$ -l highp
#$ -r y
#$ -V
source ~/.bash_profile

noOfParallelThreadsDefault=100

if test $# -lt 4
then
        echo "Usage: lftpData.sh USERNAME PASSWORD URL TARGETDIR [noOfParallelThreads]"
        echo
        echo
	echo "This script calls lftp to download data from specific URL using $noOfParallelThreads threads simultaneously into target dir."
	echo "The TARGETDIR will be made regardless of its existence."
	echo "	noOfParallelThreads is optional. default is $noOfParallelThreadsDefault."
	echo
        echo "Examples: "
	echo "  lftpData.sh someone secret https://xfer.edu/gxfer2/ genomeData/"
exit
fi


username=$1
password=$2
URL=$3
targetSubDir=$4
noOfParallelThreads=$5
if test -z "$noOfParallelThreads"
then
	noOfParallelThreads=$noOfParallelThreadsDefault
fi
echo $noOfParallelThreads threads.
mkdirhier $targetSubDir

#lftp -d -c set http:authorization aixohreesoor:ciecaimojooz ; open  https://xfer.genome.wustl.edu/gxfer2/25373303920878; set cmd:parallel 6 ; mget * 
echo "lftp -d -e set xfer:clobber false ; set http:authorization $username:$password ; open  $URL; set cmd:parallel 6 ; mirror -c --parallel=$noOfParallelThreads ./ $targetSubDir"
lftp -d -e "set xfer:clobber false; set http:authorization $username:$password; open $URL; mirror -c --parallel=$noOfParallelThreads ./ $targetSubDir"

