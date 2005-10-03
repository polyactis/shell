#!/bin/sh
echo "Which host:"
echo "1. hto-pc44"
echo "2. hto-g"
echo "3. zhoudb"
echo "4. app1"
echo "5. app2"
echo "6. zhoulab"
echo "7. gan"
echo "8. 10.113.0.1"
read a
if [ $a = "1" ]; then
	ssh hto-pc44.usc.edu -l yh
fi
if [ $a = "2" ]; then
	ssh hto-g.usc.edu -l yuhuang
fi

if [ $a = "3" ]; then
	ssh zhoudb.usc.edu -l yh
fi


if [ $a = "4" ]; then
	ssh app1.cmb.usc.edu -X -l yuhuang
fi

if [ $a = "5" ]; then
	ssh app2.cmb.usc.edu -X -l yuhuang
fi

if [ $a = "6" ]; then
	ssh zhoulab.usc.edu -l yh
fi

if [ $a = "7" ]; then
	ssh yh@gan.usc.edu
fi

if [ $a = "8" ]; then
	ssh yh@10.113.0.1
fi
