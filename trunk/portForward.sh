#!/bin/sh
if test $# -lt 6
then
	echo "Usage: $0 EXT_INTERFACE EXT_IP EXT_PORT INT_INTERFACE INT_IP INT_PORT [PROTOCOL] [CLEARCHAIN] [INTERNAL_NETWORK] [DELETE_CHAIN]"
	echo

	echo "	2010-2-23 script to forward any EXT_IP:EXT_PORT request to INT_IP:INT_PORT"
	echo 	masquerading shall be setup beforehand from INT_IP to outside on EXT_IP.
	echo "	one note: on machine INT_IP, the route to "outside" has to go through EXT_IP (no longer required due to SNAT/MASQUERADE in the end)."
	echo "	CLEARCHAIN: 0 or 1. whether to clear the PREROUTING chain of nat and FORWARD chain of filter or not."
	echo "	PROTOCOL is tcp by default."
	echo "	CLEARCHAIN will not be carried out by default."
	echo "	INTERNAL_NETWORK is 3-number representation of the network INT_INTERFACE resides in. 10.8.0 by default."
	echo "	DELETE_CHAIN: 0 or 1, whether to delete every relevant chain, useful for cleanup. Default (0) is -A (add)."
	echo
	echo "Examples:	"
	echo "	Forward ssh port of 10.0.0.7 to external port 2222. (login internal computer from outside)"
	echo "		~/script//shell/portForward.sh eth1 128.125.86.23 2222 tun0 10.0.0.7 22"
	echo "	Forward internal postgresql port to outside and cleanup PREROUTING and FORWARD chain."
	echo "		~/script//shell/portForward.sh eth1 128.125.86.23 5432 tun0 10.113.0.7 5432 tcp 1 10.113.0 1"
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
if test -n "$9"
then
	if test $9 == "1"
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

echo $IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP --dport $EXT_PORT -j DNAT --to-destination $INT_IP:$INT_PORT
$IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP --dport $EXT_PORT -j DNAT --to-destination $INT_IP:$INT_PORT

echo $IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP --dport $EXT_PORT -m limit --limit 1/second -j LOG --log-prefix "pre-route"
$IPTABLES -t nat $CHAIN_OPERATION PREROUTING -i $EXT_INTERFACE -p $PROTOCOL -d $EXT_IP --dport $EXT_PORT -m limit --limit 1/second -j LOG --log-prefix "pre-route"

#echo $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL  -d $INT_IP --dport $INT_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL  -d $INT_IP --dport $INT_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


echo $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL -d $INT_IP --dport $INT_PORT -j ACCEPT
$IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL -d $INT_IP  --dport $INT_PORT  -j ACCEPT

echo $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL  -d $INT_IP --dport $INT_PORT -m limit --limit 1/second -j LOG --log-prefix "forward from ext to internal"
$IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -p $PROTOCOL  -d $INT_IP --dport $INT_PORT -m limit --limit 1/second -j LOG --log-prefix "forward from ext to internal"

### 2011-2-23 make sure INT_IP could find its way back through the tun0 network.
### either of the two below works. By SNAT, the source IP becomes part of the network INT_IP is in.
### By MASQUERADE, the source IP becomes that of the VPN server on the tun0.
echo iptables -t nat $CHAIN_OPERATION POSTROUTING -s 0.0.0.0/0 -o $INT_INTERFACE -j SNAT -d $INT_IP --to $INTERNAL_NETWORK.50-$INTERNAL_NETWORK.253
iptables -t nat $CHAIN_OPERATION POSTROUTING -s 0.0.0.0/0 -o $INT_INTERFACE -j SNAT -d $INT_IP --to $INTERNAL_NETWORK.50-$INTERNAL_NETWORK.253
#iptables -t nat -D POSTROUTING -d $INT_IP/32 -o $INT_INTERFACE -j MASQUERADE

# echo $IPTABLES $CHAIN_OPERATION FORWARD -o $EXT_INTERFACE -i $INT_INTERFACE -p $PROTOCOL  -d $INT_IP --dport $INT_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# $IPTABLES $CHAIN_OPERATION FORWARD -o $EXT_INTERFACE -i $INT_INTERFACE -p $PROTOCOL  -d $INT_IP --dport $INT_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

## $IPTABLES $CHAIN_OPERATION FORWARD -i $INT_INTERFACE -o $EXT_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
## $IPTABLES $CHAIN_OPERATION FORWARD -i $EXT_INTERFACE -o $INT_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
