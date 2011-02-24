#!/bin/sh
## 2010-2-23 script to forward any IPADDR:DPORT request to PORTFWIP:PORTFW
## masquerading shall be setup beforehand from PORTFWIP to outside on IPADDR.
## one note: on machine PORTFWIP, the route to "outside" has to go through IPADDR (no longer required due to SNAT/MASQUERADE in the end).


IPTABLES=iptables
EXTERNAL_INTERFACE=eth1
IPADDR=128.125.86.114
DPORT=2222

PORTFWIP=10.8.0.6
PORTFW=1999
INTERNAL_INTERFACE=tun0
PROTOCOL=tcp
#PROTOCOL=udp
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 >/proc/sys/net/ipv4/ip_dynaddr
modprobe ip_conntrack
modprobe iptable_nat
modprobe iptable_mangle

$IPTABLES -F PREROUTING -t nat
$IPTABLES -F FORWARD

echo $IPTABLES -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p $PROTOCOL -d $IPADDR --dport $DPORT -j DNAT --to-destination $PORTFWIP:$PORTFW
$IPTABLES -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p $PROTOCOL -d $IPADDR --dport $DPORT -j DNAT --to-destination $PORTFWIP:$PORTFW

echo $IPTABLES -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p $PROTOCOL -d $IPADDR --dport $DPORT -m limit --limit 1/second -j LOG --log-prefix "pre-route"
$IPTABLES -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p $PROTOCOL -d $IPADDR --dport $DPORT -m limit --limit 1/second -j LOG --log-prefix "pre-route"

#echo $IPTABLES -A FORWARD -i $EXTERNAL_INTERFACE -o $INTERNAL_INTERFACE -p $PROTOCOL  -d $PORTFWIP --dport $PORTFW -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# $IPTABLES -A FORWARD -i $EXTERNAL_INTERFACE -o $INTERNAL_INTERFACE -p $PROTOCOL  -d $PORTFWIP --dport $PORTFW -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


echo $IPTABLES -A FORWARD -i $EXTERNAL_INTERFACE -o $INTERNAL_INTERFACE -p $PROTOCOL -d $PORTFWIP --dport $PORTFW -j ACCEPT
$IPTABLES -A FORWARD -i $EXTERNAL_INTERFACE -o $INTERNAL_INTERFACE -p $PROTOCOL -d $PORTFWIP  --dport $PORTFW  -j ACCEPT

echo $IPTABLES -A FORWARD -i $EXTERNAL_INTERFACE -o $INTERNAL_INTERFACE -p $PROTOCOL  -d $PORTFWIP --dport $PORTFW -m limit --limit 1/second -j LOG --log-prefix "forward from ext to internal"
$IPTABLES -A FORWARD -i $EXTERNAL_INTERFACE -o $INTERNAL_INTERFACE -p $PROTOCOL  -d $PORTFWIP --dport $PORTFW -m limit --limit 1/second -j LOG --log-prefix "forward from ext to internal"

### 2011-2-23 make sure PORTFWIP could find its way back through the tun0 network.
### either of the two below works. By SNAT, the source IP becomes part of the network PORTFWIP is in.
### By MASQUERADE, the source IP becomes that of the VPN server on the tun0.
iptables -t nat -A POSTROUTING -s 0.0.0.0/0 -o $INTERNAL_INTERFACE -j SNAT -d $PORTFWIP --to 10.8.0.0-10.8.0.253
#iptables -t nat -D POSTROUTING -d $PORTFWIP/32 -o $INTERNAL_INTERFACE -j MASQUERADE

# echo $IPTABLES -A FORWARD -o $EXTERNAL_INTERFACE -i $INTERNAL_INTERFACE -p $PROTOCOL  -d $PORTFWIP --dport $PORTFW -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# $IPTABLES -A FORWARD -o $EXTERNAL_INTERFACE -i $INTERNAL_INTERFACE -p $PROTOCOL  -d $PORTFWIP --dport $PORTFW -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

## $IPTABLES -A FORWARD -i $INTERNAL_INTERFACE -o $EXTERNAL_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
## $IPTABLES -A FORWARD -i $EXTERNAL_INTERFACE -o $INTERNAL_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
