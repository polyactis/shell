#!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -o $JOB_NAME.joblog.$JOB_ID
#$ -j y
#$ -l time=200:00:00
#$ -l highp
#$ -r y
#$ -V
source ~/.bash_profile

if test $# -lt 4
then
        echo "Usage: lftpData.sh USERNAME PASSWORD URL TARGETDIR"
        echo
        echo
	echo "This script calls lftp to download data from specific URL using 40 threads simultaneously into target dir."
	echo "The TARGETDIR will be made regardless of its existence."
	echo
        echo "Examples: "
	echo "  lftpData.sh someone secret https://xfer.edu/gxfer2/ genomeData/"
exit
fi


username=$1
password=$2
URL=$3
targetSubDir=$4
noOfParallelThreads=40
mkdir $targetSubDir

#lftp -d -c set http:authorization aixohreesoor:ciecaimojooz ; open  https://xfer.genome.wustl.edu/gxfer2/25373303920878; set cmd:parallel 6 ; mget * 
echo "lftp -d -e set xfer:clobber false ; set http:authorization $username:$password ; open  $URL; set cmd:parallel 6 ; mirror -c --parallel=$noOfParallelThreads ./ $targetSubDir"
lftp -d -e "set xfer:clobber false; set http:authorization $username:$password; open $URL; mirror -c --parallel=$noOfParallelThreads ./ $targetSubDir"

