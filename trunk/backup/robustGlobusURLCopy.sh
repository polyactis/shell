#!/bin/bash

source ~/.bash_profile

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

stderrFname=/tmp/stderr.txt
if test -w $stderrFname; then
	echo "$stderrFname is writable."
else
	echo "Error: Could not write to $stderrFname"
	exit 1
fi
#catch the stderr for later checking
$commandLine 2> $stderrFname
exitCode=$?
grep "Permission denied" $stderrFname
grepExitCode=$?
if test $exitCode != "0"; then
	cat $stderrFname
	if test $grepExitCode != "0"; then
		#keep going if it's not Permission denied error
		echo "Re-run this program ..."
		$0 $sourceDir $destinationDir
	else
		echo "Exit as permission denied is encountered."
		exit $exitCode
	fi
fi

