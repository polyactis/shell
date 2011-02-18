#!/bin/sh
#$ -pe mpich 5

if test $# -lt 2
then
	echo "Usage: wgetGivenURL.sh URLFile.txt TargetDirectory"
	echo
	echo "	Given URLs embedded in the file (lines beginned with # ignored), wget the contents recursively into TargetDirectory."
	echo "	Assume the URLs don't contain space. Not sure whether it'll be split if there is a space."
	echo
	echo "Examples:	~/script//shell/wgetGivenURL.sh ../wustl_url.txt ./"
exit
fi

urlFile=$1
targetDirectory=$2

parameter=''
#while test -n "$6"
#do
#parameter=$parameter' '$6
#shift
#done

#
for i in `awk '{if (substr($0, 1,1)!="#") {print} }' $urlFile `; do
	echo $i
	wget --retr-symlinks -c -nd -P $targetDirectory $i/*
done
