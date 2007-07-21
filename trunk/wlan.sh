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
read a
if [ $a = "1" ]; then
	route del default gw src
	iwconfig $interface essid "USC"
	iwconfig $interface key s:GOUSC
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
