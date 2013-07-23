#!/bin/sh
echo "Which host:"
echo "1. ICNNBackup, 128.97.66.147"
echo "2. vervetNFS 10.47.163.171"
echo "3. hoffman2"
echo "4. banyan"
echo "5. uclaOffice"
echo "6. bamboo"
echo "7. cli.globusonline.org"
echo "8. ssh-gw.gmi.oeaw"
echo "9. mgmt01.gmi"
echo "0. hpc-cmb.usc.edu"
echo "11. aludra.usc.edu"
echo "12. ICNNBackup, 128.97.66.154"
echo "13. autism server 149.142.126.176"
echo "a. hpc-login1.usc.edu"
echo "b. hpc-login2.usc.edu"
echo "c. vervetNFS 10.47.163.171 through icnn1"
echo "d. banyan 10.8.0.10 through icnn1"
echo "e. uclaOffice through temporary 10.47.163.167 "
echo "f. hoffman2 as namtran"
echo "g. hoffman2 as charlesb"

ICNN1IP=128.97.66.154
read a
if [ $a = "1" ]; then
	ssh 128.97.66.147 -l polyacti
fi
if [ $a = "2" ]; then
	#ssh crocea@mahogany.usc.edu -X
	#ssh hpc-opteron.usc.edu -l yuhuang -X
	ssh crocea@10.47.163.171 -X
fi

if [ $a = "3" ]; then
	#ssh zhoudb.usc.edu -l yh -X
	ssh hoffman2.idre.ucla.edu -l polyacti -X
fi


if [ $a = "4" ]; then
	ssh  -X 10.47.163.200 -l crocea
fi

if [ $a = "5" ]; then
	ssh -X crocea@149.142.212.14 -p 1999
	#ssh -X yh@10.47.163.45
	#ssh iamhere@natural.uchicago.edu
	#ssh app2.cmb.usc.edu -X -l yuhuang
fi

if [ $a = "6" ]; then
	ssh 10.47.163.137 -l crocea -X
fi

if [ $a = "7" ]; then
	#ssh yh@cypress.usc.edu -X
	ssh polyactis@cli.globusonline.org
fi

if [ $a = "8" ]; then
	ssh yu.huang@ssh-gw.gmi.oeaw.ac.at -p 22222 -X
	#ssh yh@10.113.0.1 -X 
fi

if [ $a = "9" ]; then
	ssh yu.huang@mgmt01.gmi.oeaw.ac.at -X
	#ssh yuhuang@hpc.usc.edu -X 
fi

if [ $a = "0" ]; then
	ssh yuhuang@hpc-cmb.usc.edu -X
fi

if [ $a = "11" ]; then
	ssh yuhuang@aludra.usc.edu -X
	#ssh yh@gan.usc.edu -X
fi
if [ $a = "12" ]; then
	#echo "12. banyan through dl324b-1"
	#ssh -p 2222 dl324b-1.cmb.usc.edu -l crocea -X
	ssh $ICNN1IP -l polyacti
fi

if [ $a = "13" ]; then
	ssh yh@149.142.126.176 -X	#2012.4.3 new IP
	#ssh yh@10.47.165.148 -X
fi

if [ $a = "a" ]; then
	ssh yuhuang@hpc-login1.usc.edu -X
fi

if [ $a = "b" ]; then
	ssh yuhuang@hpc-login2.usc.edu -X
fi

if [ $a = "c" ]; then
	ssh -p 22222 $ICNN1IP -l crocea -X
fi
if [ $a = "d" ]; then
	ssh -p 2222 $ICNN1IP -l crocea -X
fi

if [ $a = "e" ]; then
	ssh crocea@10.47.163.167 -p 1999
fi

if [ $a = "f" ]; then
	ssh hoffman2.idre.ucla.edu -l namtran
fi

if [ $a = "g" ]; then
	ssh hoffman2.idre.ucla.edu -l charlesb 
fi
