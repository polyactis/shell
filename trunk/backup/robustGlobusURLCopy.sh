#!/bin/bash

if test $# -lt 2; then
	echo "Usage:"
	echo "  $0 SOURCE DESTINATION"
	echo ""
	echo "Note:"
	echo "	#. This program restart the globus-url-copy if it exits non-zero (fail for whatever reason)."
	echo "	#. append the star wildcard (*) in the SOURCE."
	echo "	#. append the slash sign to DESTINATION."
	echo
	echo "Examples:"
	echo "	#"
	echo "	$0 gsiftp://grid4.hoffman2.idre.ucla.edu/u/home/eeskin/namtran/[0-9a-zA-Z]* file:///h0/namtran/"
	echo
	echo
	exit 1
fi
sourceDir=$1
destinationDir=$2

globusURLCopyPath=`which globus-url-copy`
commandLine="$globusURLCopyPath -sync-level 2 -sync -p 40 -vb -r $sourceDir $destinationDir"
echo commandLine is $commandLine

$commandLine
exitCode=$?
if test $exitCode != "0"; then
	$0 $sourceDir $destinationDir
fi

