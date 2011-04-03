#!/bin/sh
echo "Which host:"
echo "1. dl324b-1"
echo "2. mahogany"
echo "3. hoffman2"
echo "4. banyan"
echo "5. uclaOffice"
echo "6. bamboo"
echo "7. cypress"
echo "8. ssh-gw.gmi.oeaw"
echo "9. mgmt01.gmi"
echo "0. hpc-cmb.usc.edu"
echo "11. aludra.usc.edu"
read a
if [ $a = "1" ]; then
	ssh dl324b-1.cmb.usc.edu -l yh -X
fi
if [ $a = "2" ]; then
	ssh crocea@mahogany.usc.edu -X
	#ssh hpc-opteron.usc.edu -l yuhuang -X
fi

if [ $a = "3" ]; then
	#ssh zhoudb.usc.edu -l yh -X
	ssh hoffman2.idre.ucla.edu -l polyacti -X
fi


if [ $a = "4" ]; then
	ssh  -X 10.47.163.200 -l crocea
fi

if [ $a = "5" ]; then
	ssh -X yh@149.142.212.14 -p 1999
	#ssh -X yh@10.47.163.45
	#ssh iamhere@natural.uchicago.edu
	#ssh app2.cmb.usc.edu -X -l yuhuang
fi

if [ $a = "6" ]; then
	ssh bamboo.usc.edu -l crocea -X
fi

if [ $a = "7" ]; then
	ssh yh@cypress.usc.edu -X
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
