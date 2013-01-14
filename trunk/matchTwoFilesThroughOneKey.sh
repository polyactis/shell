#!/bin/bash
if test $# -lt 5; then
	echo "  $0 keyColumnNumberInFile1 keyColumnNumberInFile2 fname1 fname2 outputFname"
	echo ""
	echo "This program outputs the lines that exist in both files according to designated key column in each file."
	echo ""
	echo "Note:"
	echo "	1. the columnNumber is 1-based."
	echo "	2. In the output, overlapping lines of two files are joined in one line via tab. So your input are better be delimited via tab."
	echo ""
	echo "Examples:"
	echo "	 $0 1 1 input1.tsv input2.tsv output.tsv"
	exit 1
fi
shellDir=`dirname $0`
source $shellDir/common.sh


keyColumnNumberInFile1=$1
keyColumnNumberInFile2=$2
fname1=$3;
fname2=$4;
outputFname=$5

exitIfFileExists $outputFname

awk 'FNR==NR{a[$'$keyColumnNumberInFile1']=$0} NR>FNR && ($'$keyColumnNumberInFile2' in a){ print a[$'$keyColumnNumberInFile2']"\t"$0 } ' $fname1 $fname2 > $outputFname
