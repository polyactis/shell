#!/bin/sh
if test $# -lt 1
then
	echo "Usage: $0 SUBNETWORK"
	echo
	echo "	2011-4-4"
	echo "	script to enable masquerade (iptables -t nat) for a subnetwork."

	echo
	echo "Examples:	"
	echo "		~/script/shell/masq.sh 192.168.3.0"
exit
fi
subnetwork=$1

echo 1 >/proc/sys/net/ipv4/ip_forward
echo 1 >/proc/sys/net/ipv4/ip_dynaddr
iptables -t nat -P POSTROUTING ACCEPT 
iptables -t nat -A POSTROUTING  -s $subnetwork/24 ! -d $subnetwork/24 -j MASQUERADE
#iptables -t nat -A POSTROUTING -o eth1 -s 10.100.113.60/32 -d ! 10.0.0.0/8 -j MASQUERADE  
#iptables -t nat -A POSTROUTING -o eth1 -s 10.100.113.96/32 -d ! 10.0.0.0/8 -j MASQUERADE
