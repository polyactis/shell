#!/bin/bash

if test $# -lt 2; then
	echo "  $0 inputMatrix columnNumber"
	echo ""
	echo "This program outputs the number of lines in which one column(AKA key)'s value occurs."
	echo ""
	echo "Note:"
	echo ""
	exit 1
fi

fname=$1;
fieldNo=$2;

awk ' (FNR==1){a[$'$fieldNo']=1}  {if ($'$fieldNo' in a){a[$'$fieldNo']=a[$'$fieldNo']+1} else {a[$'$fieldNo']=1}} END {for (key in a ) {print key "\t" a[key]}}' $fname |sort -k 2 -n 

