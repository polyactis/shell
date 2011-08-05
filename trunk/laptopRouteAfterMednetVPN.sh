#!/bin/sh

if test -z $1
then
	#if $1 is empty, make up something. empty $1 would cause error reporting in 'test $argument="-h"'.
	argument="whatever";
else
	argument=$1
fi


if test $argument = "-h"
then
	echo "Usage: $0"
	echo
	echo "	2011-7-6"
	echo "	When laptop is at UCLA, "
	echo "	remove the 149.142.0.0 network from the tun0 route after laptop established openvpn to dl324b-1"

	echo
	echo "Examples:	"
	echo "		~/script//shell/laptopRouteAfterVPN.sh"
	exit
fi
echo $#
echo $@

# 128.125.86.114 is where the vpn server is, its gateway is the original default gateway..
uclaGW=`route -n |grep ^128.125.86.114|awk '{print $2}'`
#assume now openvpn has replaced the default gateway with whatever it is. Even if it hasn't replaced it, it meant now harm.
openVPNDefaultGW=`route -n |grep ^0.0.0.0|awk '{print $2}'`
route del -net 149.142.0.0 netmask 255.255.0.0 dev tun0

