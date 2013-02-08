#!/bin/sh

if test $# -lt 2
then
	echo "Usage:"
	echo "    check_node.sh NODE_HOSTNAME INTERVAL_IN_SECONDS [OUTPUT_FNAME]"
	echo ""
	echo "check memory usage and other info on a particular node by 'vmstat'."
	echo "output is appended to status_\$hostname.txt if OUTPUT_FNAME is not given."
	echo
	echo "Example: check_node.sh hpc2227 3"
	echo
	exit
fi


hostname=$1
sec_interval=$2
i=1
if test -n $3
then
	output_fname=status_$hostname\.txt
else
	output_fname=$3
fi
while [ $i>0 ];
do
	date >> $output_fname;
	ssh $hostname vmstat >> $output_fname 2>>$output_fname;
	sleep $sec_interval\s
done
