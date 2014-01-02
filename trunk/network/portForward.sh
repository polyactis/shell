#!/bin/sh
if test $# -lt 6
then
	echo "Usage: $0 EXT_INTERFACE EXT_IP EXT_PORT INT_INTERFACE INT_IP INT_PORT [PROTOCOL] [CLEARCHAIN] [INTERNAL_NETWORK] [DELETE_RULE]"
	echo

	echo "	2010-2-23 script to forward any EXT_IP:EXT_PORT request to INT_IP:INT_PORT"
	echo 	masquerading shall be setup beforehand from INT_IP to outside on EXT_IP.
	echo "	one note: on machine INT_IP, the route to "outside" has to go through EXT_IP (no longer required due to SNAT/MASQUERADE in the end)."
	echo "	CLEARCHAIN: 0 or 1. whether to clear the PREROUTING chain of nat and FORWARD chain of filter or not."
	echo "	PROTOCOL is tcp by default."
	echo "	CLEARCHAIN will not be carried out by default."
	echo "	INTERNAL_NETWORK is 3-number representation of the network INT_INTERFACE resides in. 10.8.0 by default."
	echo "	DELETE_RULE: 0 or 1. this controls the iptables command. Default (0) is -A (add). 1: -D (delete rules from chain)."
	echo
	echo "Examples:	"
	echo "	Forward ssh port of 10.0.0.7 to external port 2222. (login internal computer from outside)"
	echo "		~/script//shell/portForward.sh eth1 128.125.86.23 2222 tun0 10.0.0.7 22"
	echo "	Instead of adding, instruct iptables to delete all rules related to this setting (forwarding internal postgresql port to outside) , whether it's there all not. Good for targeted cleanup."
	echo "		~/script//shell/portForward.sh eth1 128.125.86.23 5432 tun0 10.113.0.7 5432 tcp 0 10.113.0 1"
	echo "	Clear/flush the PREROUTING and FORWARD chain before forwarding internal postgresql port to outside."
	echo "		~/script//shell/portForward.sh eth1 128.125.86.23 5432 tun0 10.113.0.7 5432 tcp 1 10.113.0"
	echo "	Forward port range 40000-45000 of 10.0.0.7 to external same port range."
	echo "		~/script//shell/portForward.sh eth1 128.125.86.23 40000:45000 tun0 10.0.0.7 40000:45000"
exit
fi

IPTABLES=iptables

EXT_INTERFACE=$1
EXT_IP=$2
EXT_PORT=$3

INT_INTERFACE=$4
INT_IP=$5
INT_PORT=$6

PROTOCOL=tcp
if test -n "$7"
then
	PROTOCOL=$7
fi

CLEARCHAIN=0
if test -n "$8"
then
	CLEARCHAIN=$8
fi

INTERNAL_NETWORK=10.8.0
if test -n "$9"
then
	INTERNAL_NETWORK=$9
fi

CHAIN_OPERATION=-A
shift
DELETE_RULE=$9
if test -n "$DELETE_RULE"
then
	if test "$DELETE_RULE" = "1"
	then
		CHAIN_OPERATION=-D
	fi
fi

#PROTOCOL=udp
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 >/proc/sys/net/ipv4/ip_dynaddr
modprobe ip_conntrack
modprobe iptable_nat
modprobe iptable_mangle

if test $CLEARCHAIN = "1"
then
	$IPTABLES -F PREROUTING -t nat
	$IPTABLES -F FORWARD
fi

# before routing, destination-NAT: translate any request to EXT_IP:EXT_PORT to a request to INT_IP:INT_PORT
# 2014.01.01 somehow this option is not working well, related to "--sports $INT_PORT". so use the alternative below this.
#echo $IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP -m multiport --dports $EXT_PORT -j DNAT --to-destination $INT_IP -m multiport --sports $INT_PORT
#$IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP -m multiport --dports $EXT_PORT -j DNAT --to-destination $INT_IP -m multiport --sports $INT_PORT

### 2011-8-4 INT_PORT in "--to-destination $INT_IP:$INT_PORT " below uses a different format, port1-port2, rather than port1:port2, to describe a port range.
#. So opt to use multiport from above to keep consistency.
## 2014.01.01 activated this method because somehow method above stopped working.
echo $IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP -m multiport --dports $EXT_PORT -j DNAT --to-destination $INT_IP:$INT_PORT
$IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP -m multiport --dports $EXT_PORT -j DNAT --to-destination $INT_IP:$INT_PORT

# log (not really working)
#echo $IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP -m multiport --dports $EXT_PORT -m limit --limit 1/second -j LOG --log-prefix "pre-route"
#$IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP -m multiport --dports $EXT_PORT -m limit --limit 1/second -j LOG --log-prefix "pre-route"

#echo $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL  -d $INT_IP -m multiport --dports $INT_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL  -d $INT_IP -m multiport --dports $INT_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

#forward external interface to internal interface
echo $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL -d $INT_IP -m multiport --dports $INT_PORT -j ACCEPT
$IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL -d $INT_IP  -m multiport --dports $INT_PORT  -j ACCEPT

# log (not working)
#echo $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL  -d $INT_IP -m multiport --dports $INT_PORT -m limit --limit 1/second -j LOG --log-prefix "forward from ext to internal"
#$IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL  -d $INT_IP -m multiport --dports $INT_PORT -m limit --limit 1/second -j LOG --log-prefix "forward from ext to internal"

# echo log
#echo $IPTABLES $CHAIN_OPERATION INPUT -m state --state NEW -p tcp -m multiport --dports 80 -j LOG --log-prefix "NEW_HTTP_CONN:"

### 2011-2-23 make sure INT_IP could find its way back through the tun0 network.
### either of the two below works. By SNAT, the source IP becomes part of the network INT_IP is in.
### By MASQUERADE, the source IP becomes that of the VPN server on the tun0.
# after routing, source NAT, translate requests from any IP on the INT_INTERFACE to a range 50-253 on the internal network
echo iptables -t nat $CHAIN_OPERATION POSTROUTING -s 0.0.0.0/0 -o $INT_INTERFACE -j SNAT -d $INT_IP --to $INTERNAL_NETWORK.50-$INTERNAL_NETWORK.253
iptables -t nat $CHAIN_OPERATION POSTROUTING -s 0.0.0.0/0 -o $INT_INTERFACE -j SNAT -d $INT_IP --to $INTERNAL_NETWORK.50-$INTERNAL_NETWORK.253
#iptables -t nat -D POSTROUTING -d $INT_IP/32 -o $INT_INTERFACE -j MASQUERADE

# echo $IPTABLES $CHAIN_OPERATION FORWARD -o $EXT_INTERFACE -i $INT_INTERFACE -p $PROTOCOL  -d $INT_IP -m multiport --dports $INT_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# $IPTABLES $CHAIN_OPERATION FORWARD -o $EXT_INTERFACE -i $INT_INTERFACE -p $PROTOCOL  -d $INT_IP -m multiport --dports $INT_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

## $IPTABLES $CHAIN_OPERATION FORWARD -i $INT_INTERFACE -o $EXT_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
## $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
