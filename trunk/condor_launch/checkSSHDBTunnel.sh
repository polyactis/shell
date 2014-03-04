#!/bin/bash
targetHost=crocea.mednet.ucla.edu
#2014.03.03 use ICNN1 as db server
targetHost=128.97.66.147
targetPort=5432
noOfGrepLines=`ps -ef OT|grep $targetHost:$targetPort|wc -l`
#ulimit -n 50000 #2013.3.24 no need for these anymore. only one ssh tunnel process per node
#ulimit -u 50000
if test "$noOfGrepLines" = "2"; then	#sshTunnel is there. grep process will show up in ps -ef OT.
	echo "sshDBTunnel=1"
else
	echo "sshDBTunnel=0"
	#2012.4.16 add sshDBTunnel classAd for this machine
	#echo "sshDBTunnel=$sshDBTunnel" >>$localCondorConfigFile
	#ssh -N -L 5432:dl324b-1.cmb.usc.edu:5432 polyacti@login3 & 
	#tunnelProcessID=0
fi

