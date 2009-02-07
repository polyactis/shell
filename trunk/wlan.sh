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
echo "3. sbc"
echo "4. portland"
echo "5. hto_eth0"
echo "6. w1141"
echo "7. default"
echo "8. ipam"
echo "9. DLINK_WIRELESS"
#echo "0. SMBE kubi"
echo "0. aliso creek"
echo "10. Big Sky, Montana"
echo "11. FFGG"
read a
if [ $a = "1" ]; then
	route del default gw src
	iwconfig $interface essid "USC Wireless"
	iwconfig $interface key open
	iwconfig $interface key off
	#iwconfig $interface key s:GOUSC
	dhclient $interface
fi
if [ $a = "2" ]; then
	route del default gw src
	iwconfig $interface essid "Math Grad Lab"
	dhclient $interface
fi

if [ $a = "3" ]; then
	route del default gw src
	iwconfig $interface essid "sbc"
	iwconfig $interface key E9D65EDFACAB792AB74C57C5D3
	dhclient $interface
fi


if [ $a = "4" ]; then
	ifconfig eth0 down
	route del default gw src
	iwconfig $interface essid "portland"
	iwconfig $interface key C758C65F16616BA8D2489C67BE
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
	iwconfig $interface essid "Wei"
	iwconfig $interface key "7BCEEE359D"
	dhclient $interface
fi

if [ $a = "7" ]; then
	ifconfig eth0 down
	route del default gw src
	iwconfig $interface essid "default"
	iwconfig $interface key open
	iwconfig $interface key off
	dhclient $interface
fi

if [ $a = "8" ]; then
	ifconfig eth0 down
	route del default gw src
	iwconfig $interface essid "ipam"
	iwconfig $interface key 6F737472696368657332313433
	dhclient $interface
fi

if [ $a = "9" ]; then
	ifconfig eth0 down
	iwconfig $interface essid "DLINK_WIRELESS"
	iwconfig $interface key off
	dhclient $interface
fi

if [ $a = "199" ]; then
	ifconfig eth0 down
	iwconfig $interface essid "kubi"
	iwconfig $interface key off
	dhclient $interface
fi

if [ $a = "0" ]; then	#SMBE
	ifconfig eth0 down
	route del default gw src
	#iwconfig $interface essid "u5czp568"
	#iwconfig $interface essid CAULAINCOURT #2008 SMBE Barcelona
	iwconfig $interface essid "ACI Wireless"
	iwconfig $interface key off
	dhclient $interface
fi
if [ $a = "10" ]; then
	ifconfig eth0 down
	iwconfig $interface essid "GlobalSuiteWireless"
	iwconfig $interface key off
	dhclient $interface
fi
if [ $a = "11" ]; then
	ifconfig eth0 down
	iwconfig $interface essid "FFGG"
	iwconfig $interface key "2138393939"
	#dhclient $interface
	ifconfig ath0 192.168.10.177
	route add default gw 192.168.10.2
fi
