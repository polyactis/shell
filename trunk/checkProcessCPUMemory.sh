#!/bin/bash

if test $# -lt 2
then
	echo "Usage:"
	echo "    $0 username statOutputFilename"
	echo ""
	echo "check cpu and memory usage of processes owned by a user on a machine. It runs 'ps'."
	echo "output is appended to  OUTPUT_FNAME ."
	echo
	echo "Example: $0 yhuang2 ~/processCPUMemoryStat.txt"
	echo
	exit
fi

username=$1
outputFname=$2
while  test 1 -ge 0  ; do
	date |tee -a $outputFname
	ps -o pid,ppid,pcpu,pmem,stime,stat,time,user,cmd -U $username | tee -a $outputFname
	sleep 5s
done
