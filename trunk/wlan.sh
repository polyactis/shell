#!/bin/sh
echo "Wireless interface:"
echo "a. ath0"
echo "e. eth1"
read choice
if [ $choice = "a" ]; then
	interface="ath0"
fi
if [ $choice = "e" ]; then
	interface="eth1"
fi
echo "Which essid:"
echo "1. USC"
echo "2. Math"
echo "3. zzhao"
echo "4. hto-ww"
echo "5. hto_eth0"
echo "6. belkin54g"
read a
if [ $a = "1" ]; then
	route del default gw src
	iwconfig $interface essid "USC"
	iwconfig $interface key s:GOUSC
	dhclient $interface
fi
if [ $a = "2" ]; then
	route del default gw src
	iwconfig $interface essid "Math"
	dhclient $interface
fi

if [ $a = "3" ]; then
	route del default gw src
	iwconfig $interface essid "zzhao"
	iwconfig $interface key 1234567890
	ifconfig eth0 10.100.113.107
	dhclient $interface
	#ifconfig $interface 192.168.0.147
	#route add default gw src
fi


if [ $a = "4" ]; then
	route del default gw src
	iwconfig $interface essid "hto-ww"
	#ifconfig eth0 down
	dhclient $interface
fi

if [ $a = "5" ]; then
	route del default gw src
	ifconfig $interface down
	dhclient eth0
	ifconfig $interface down
fi

if [ $a = "6" ]; then
	route del default gw src
	iwconfig $interface essid "belkin54g"
	dhclient $interface
fi
