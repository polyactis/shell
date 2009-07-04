#!/bin/sh
echo "Which host:"
echo "1. dl324b-1"
echo "2. mahogany"
echo "3. zhoudb"
echo "4. banyan"
echo "5. natural.uchicago.edu"
echo "6. zhoulab"
echo "7. cypress"
echo "8. 10.113.0.1"
echo "9. hpc.usc.edu"
echo "0. hpc-cmb.usc.edu"
echo "11. gan"
read a
if [ $a = "1" ]; then
	ssh dl324b-1.cmb.usc.edu -l yh -X
fi
if [ $a = "2" ]; then
	ssh yh@mahogany.usc.edu -X
	#ssh hpc-opteron.usc.edu -l yuhuang -X
fi

if [ $a = "3" ]; then
	ssh zhoudb.usc.edu -l yh -X
fi


if [ $a = "4" ]; then
	ssh banyan.usc.edu -X -l crocea
fi

if [ $a = "5" ]; then
	ssh iamhere@natural.uchicago.edu
	#ssh app2.cmb.usc.edu -X -l yuhuang
fi

if [ $a = "6" ]; then
	ssh zhoulab.usc.edu -l yh -X
fi

if [ $a = "7" ]; then
	ssh yh@cypress.usc.edu -X
fi

if [ $a = "8" ]; then
	ssh yh@10.113.0.1 -X 
fi

if [ $a = "9" ]; then
	ssh yuhuang@hpc.usc.edu -X 
fi

if [ $a = "0" ]; then
	ssh yuhuang@hpc-cmb.usc.edu -X
fi

if [ $a = "11" ]; then
	ssh yh@gan.usc.edu -X
fi
