#!/bin/sh
if test $# -ne 2 
then
	echo "Usage:"
	echo "    mdb_output.sh source organism"
	echo 
	echo " organism is small case two-letter"
	echo " call microarraydb.py to output datasets from mdb, Gene ID"
	echo
	exit
fi

source=$1
organism=$2

if test -d $directory;then
	directory=~/datasets/$organism\_gene
fi

mkdir $directory

#the python library path
source ~/.bash_profile
date

echo ~/script/microarray/bin/microarraydb.py -s $source -o $directory -g $organism
~/script/microarray/bin/microarraydb.py -s $source -o $directory -g $organism

date
