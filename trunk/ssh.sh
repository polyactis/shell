#!/bin/sh
echo "Which host:"
echo "1. dl324b-1"
echo "2. hpc-opteron"
echo "3. zhoudb"
echo "4. dl324b-2"
echo "5. app2"
echo "6. zhoulab"
echo "7. gan"
echo "8. 10.113.0.1"
echo "9. hpc.usc.edu"
echo "0. hpc-cmb.usc.edu"
read a
if [ $a = "1" ]; then
	ssh dl324b-1.cmb.usc.edu -l yh -X
fi
if [ $a = "2" ]; then
	ssh hpc-opteron.usc.edu -l yuhuang -X
fi

if [ $a = "3" ]; then
	ssh zhoudb.usc.edu -l yh -X
fi


if [ $a = "4" ]; then
	ssh dl324b-2.cmb.usc.edu -X -l yh
fi

if [ $a = "5" ]; then
	ssh app2.cmb.usc.edu -X -l yuhuang
fi

if [ $a = "6" ]; then
	ssh zhoulab.usc.edu -l yh -X
fi

if [ $a = "7" ]; then
	ssh yh@gan.usc.edu -X
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
