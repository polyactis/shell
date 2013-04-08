#!/bin/sh

outputFnameDefault="dfStorage.txt"
outputFname=$1
if test -z $outputFname; then
	outputFname=$outputFnameDefault
fi

while test "1" = "1";do
	date|tee -a $outputFname
	df -h|grep ee |tee -a $outputFname
	du -sh /u/scratch//p/polyacti/pegasus/* |tee -a $outputFname
	sleep 5
done
