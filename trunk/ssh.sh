#!/bin/sh
echo "Which host:"
echo "1. hto-pc44"
echo "2. hto-g"
echo "3. zhoudb"
echo "4. app1"
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
	ssh app1.cmb.usc.edu -l yuhuang
fi

