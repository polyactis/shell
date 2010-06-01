#!/bin/sh
if test $# -lt 1
then
	echo "Usage:"
	echo "	kill_jobs.sh PATTERN [KILLSIGNAL]"
	echo
	echo "This script kills jobs by pattern-grepping (ps -ef|grep PATTERN)."
	echo "	KILLSIGNAL is optional. Default is TERM/15."
	exit
fi

if test -n "$2" ; then
	kill_signal=$2
else
	kill_signal=15
fi

pattern=$1
for i in `ps -ef |grep $pattern|awk '{print $2}'`;do echo $i; kill -$kill_signal $i; done
