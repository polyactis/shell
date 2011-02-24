#!/bin/sh
if test $# -lt 2
then
	echo "Usage: $0 uclaGW openVPNDefaultGW"
	echo
	echo "	2011-2-23"
	echo "	this is for gateway setup after openvpn is established between ucla Office desktop and dl324b-1.cmb"

	echo
	echo "Examples:	"
	echo "		~/script//shell/uclarouteAfterOpenVPN.sh 149.142.212.1 10.8.0.5"
exit
fi
#uclaGW=10.47.163.1
uclaGW=$1	#2011-2-23
openVPNDefaultGW=$2
route add -net 10.47.0.0 gw $uclaGW netmask 255.255.0.0
route add -net 10.3.0.0 gw $uclaGW netmask 255.255.0.0
route del default gw $openVPNDefaultGW
route add default gw $uclaGW
