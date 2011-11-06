#!/bin/sh

username='yuhuang'
qstat_commandline="qstat | grep $username"
echo $qstat_commandline
for job_id in `qstat | grep $username |awk '{print $1}'|awk 'BEGIN {FS="."} {print $1}'`
	do echo $job_id
	#qdel $job_id
done
