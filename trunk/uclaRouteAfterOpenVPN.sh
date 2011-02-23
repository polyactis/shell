#!/bin/sh
###
## 2011-2-23
## this is for gateway setup after openvpn is established between ucla Office desktop and dl324b-1.cmb
###
#uclaGW=10.47.163.1
uclaGW=149.142.212.1	#2011-2-23
openVPNDefaultGW=10.8.0.9
route add -net 10.47.0.0 gw $uclaGW netmask 255.255.0.0
route add -net 10.3.0.0 gw $uclaGW netmask 255.255.0.0
route del default gw $openVPNDefaultGW
route add default gw $uclaGW
