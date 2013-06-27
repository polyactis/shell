#!/bin/sh


if test $# -lt 1 ; then
	echo "  $0 clusterUsername [realDelete]"
	echo ""
	echo "Note:"
	echo "	#. This program will grep all jobs belonging to that given user, clusterUsername and qdel them."
	echo "	#. If argument realDelete is non-empty, this script qdels all jobs. Otherwise, it displays all the job IDs."
	exit 1
fi

username=$1
realDelete=$2
qstat_commandline="qstat | grep $username"
echo $qstat_commandline
for job_id in `qstat | grep $username |grep qw | awk '{print $1}'|awk 'BEGIN {FS="."} {print $1}'`
	do echo $job_id
	if test $realDelete
	then
		#realDelete is non-empty
		qdel $job_id
	fi
done
