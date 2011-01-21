#!/bin/sh

if test -n "$1" ; then
	host=$1
else
	host=oak.usc.edu
fi
echo ping $host
while [ 0==0 ];do
	date
	ping -c 2 $host
	sleep 15s
done
