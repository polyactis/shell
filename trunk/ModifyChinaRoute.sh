#!/bin/sh
# 2011-6-6 a script to modify routing table when the computer is in china 
if test $# -lt 1
then
	echo "Usage: ModifyChinaRoute.sh DefaultGW"
	echo
	echo
	echo "Examples:	~/script//shell/ModifyChinaRoute.sh 10.113.0.5"
exit
fi

if test -n $1
then
	defaultGW=$1
else
	defaultGW=10.113.0.5
fi


gw=$defaultGW
echo Default gateway is $gw.

for ip in 170.149.173.130 74.125.71.19 82.94.164.168 149.142.49.108  74.217.192.150 174.129.29.206 174.36.228.137 174.36.228.136 195.93.80.36 74.125.71.138 157.166.255.19 ; do
	echo $ip;
	route add -host $ip gw $gw
done

for ip in 143.166.0.0 74.125.0.0 209.85.0.0 243.185.0.0; do
	echo $ip;
	route add -net $ip netmask 255.255.0.0 gw $gw
done
