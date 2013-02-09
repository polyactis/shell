#!/bin/bash

pageNumberIncreasingStepDefault=2
newFileSuffixDefault=.jpg
if test $# -lt 4 ; then
	echo "  $0 inputFolder currentFilePrefix newFilePrefix pageStartingNumber [pageNumberIncreasingStep] [newFileSuffix]"
	echo ""
	echo "Warning:"
	echo "	1. Before starting to rename the files, you should keep in mind the new filenames set should not overlap with the old filenames set. Otherwise, file loss may happen."
	echo "	2. The number of files selected within the folder should be <= 9999."
	echo "Notes:"
	echo "	1. pageNumberIncreasingStep is $pageNumberIncreasingStepDefault by default."
	echo "	2. newFileSuffix is $newFileSuffixDefault by default."
	echo "	3. new filenames look like newFilePrefix_pageNumber newFileSuffix"
	echo
	echo "Examples:"
	echo "	Change all files in ~ with uni prefix to prefix=un and starting page number is 0. New filename is like un_0000.jpg"
	echo "	$0 ~ uni un 0"
	exit 1
fi

inputFolder=$1
currentFilePrefix=$2
newFilePrefix=$3
pageStartingNumber=$4
pageNumberIncreasingStep=$5
if [ -z $pageNumberIncreasingStep ]
then
	pageNumberIncreasingStep=$pageNumberIncreasingStepDefault
fi

newFileSuffix=$6
if [ -z $newFileSuffix ]
then
	newFileSuffix=$newFileSuffixDefault
fi

#echo -n "Please enter the current prefix for all these files: "
#read oldPrefix
#echo -n "Please enter the new prefix for all these files: "
#read prefix
#echo -n "Enter the base number: "
#read base
#echo -n "What is the increasing unit, 1 or 2?"
#read unit
pageNumber=$pageStartingNumber
count=$pageNumber

#cd  $1

echo "The folder is: $inputFolder"
echo "Files to be changed has this prefix: $currentFilePrefix"
echo "new file prefix: $newFilePrefix"
echo "new file suffix: $newFileSuffix"
echo "pageStartingNumber: $pageStartingNumber"
echo "pageNumberIncreasingStep: $pageNumberIncreasingStep"

echo -n "Continue? (y/n): "
read answer

if [ $answer = 'y' ]
then

	for i in `ls $inputFolder/$currentFilePrefix*`
	do
		if test -w $i
		then
			if `test -f $i`
			then
				if [ $pageNumber -lt 10 ]
				then
					pageNumber=000$pageNumber
				elif [ $pageNumber -lt 100 ]
				then
					pageNumber=00$pageNumber
				elif [ $pageNumber -lt 1000 ]
				then
					pageNumber=0$pageNumber
				fi
				mv -i $i $newFilePrefix\_$pageNumber$newFileSuffix
				pageNumber=`expr $pageNumber \+ $pageNumberIncreasingStep`
				count=`expr $count \+ 1`
			fi
		fi
	done

else
	echo "you answered no"
fi

echo `expr $count \- $pageStartingNumber` "filenames reordered"
