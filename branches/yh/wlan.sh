#!/bin/sh
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
	iwconfig ath0 essid "USC"
	iwconfig ath0 key s:GOUSC
	dhclient ath0
fi
if [ $a = "2" ]; then
	route del default gw src
	iwconfig ath0 essid "Math"
	dhclient ath0
fi

if [ $a = "3" ]; then
	route del default gw src
	iwconfig ath0 essid "zzhao"
	iwconfig ath0 key 1234567890
	ifconfig eth0 10.100.113.107
	ifconfig ath0 192.168.0.147
	route add default gw src
fi


if [ $a = "4" ]; then
	route del default gw src
	iwconfig ath0 essid "hto-ww"
	#ifconfig eth0 down
	dhclient ath0
fi

if [ $a = "5" ]; then
	route del default gw src
	ifconfig ath0 down
	dhclient eth0
	ifconfig ath0 down
fi

if [ $a = "6" ]; then
	route del default gw src
	iwconfig ath0 essid "belkin54g"
	dhclient ath0
fi
