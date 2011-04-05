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
	echo "	2011-2-23"
	echo "	this script removes the default gateway given by openvpn after vpn is established between ucla computers and dl324b-1.cmb"

	echo
	echo "Examples:	"
	echo "		~/script//shell/uclarouteAfterOpenVPN.sh"
	exit
fi
echo $#
echo $@

# 128.125.86.114 is where the vpn server is, its gateway is the original default gateway..
uclaGW=`route -n |grep ^128.125.86.114|awk '{print $2}'`
#assume now openvpn has replaced the default gateway with whatever it is. Even if it hasn't replaced it, it meant now harm.
openVPNDefaultGW=`route -n |grep ^0.0.0.0|awk '{print $2}'`

if test -n $openVPNDefaultGW
then
	echo route del default gw $openVPNDefaultGW
	route del default gw $openVPNDefaultGW
fi

if test -n $uclaGW
then
	echo route add default gw $uclaGW
	route add default gw $uclaGW
fi
