#!/bin/sh
# 2011-4-4
# 	script to establish an openvpn connection without changing the default gw
#
#

# must be executed before the openvpn init script
oldDefaultGW=`route -n |grep ^0.0.0.0|awk '{print $2}'`
/etc/init.d/openvpn start
sleep 3;	#wait 3 seconds for the tun0 to be setup
vpnDefaultGW=`route -n |grep ^0.0.0.0|awk '{print $2}'`
echo route del default gw $vpnDefaultGW
echo route add default gw $oldDefaultGW
