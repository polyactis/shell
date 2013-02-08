#!/bin/sh
# 2011-4-4
# 	script to establish an openvpn connection without changing the default gw
#
#

# first look for the gateway to dl324b-1.cmb.usc.edu (vpn server), if not successful, look for default.
# this part is required if the openvpn is already running. The default gateway would be the vpn gateway.
oldDefaultGW=`route -n |grep ^128.125.86.114|awk '{print $2}'`

if test -z $oldDefaultGW
then
	# must be executed before the openvpn init script
	oldDefaultGW=`route -n |grep ^0.0.0.0|awk '{print $2}'`
fi

/etc/init.d/openvpn restart
sleep 3;	#wait 3 seconds for the tun0 to be setup
vpnDefaultGW=`route -n |grep ^0.0.0.0|awk '{print $2}'`
echo route del default gw $vpnDefaultGW
route del default gw $vpnDefaultGW
echo route add default gw $oldDefaultGW
route add default gw $oldDefaultGW
