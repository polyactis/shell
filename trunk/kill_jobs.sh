#!/bin/sh
if test $# -lt 1
then
	echo "Usage:"
	echo "	kill_jobs.sh PATTERN [KILLSIGNAL]"
	echo
	echo "This script kills jobs by pattern-grepping (ps -ef|grep PATTERN)."
	echo "	You will be asked to confirm before killing."
	echo "	KILLSIGNAL is optional. Default is TERM/15."
	exit
fi

if test -n "$2" ; then
	kill_signal=$2
else
	kill_signal=15
fi

pattern=$1
echo "Processed to be killed are:"
ps -ef |grep $pattern| awk '{print}'
echo -n "Continue to kill?(Y/n):"
read yes_or_no;
if test -n "$yes_or_no"; then
	yes_or_no=$yes_or_no
else
	yes_or_no="Y"
fi
echo $yes_or_no
if test $yes_or_no = "Y" -o $yes_or_no = "y" -o $yes_or_no = "Yes" -o $yes_or_no = "yes" -o $yes_or_no = "YES" ; then
	for i in `ps -ef |grep $pattern|awk '{print $2}'`; do
		echo $i
		kill -$kill_signal $i;
	done
fi
