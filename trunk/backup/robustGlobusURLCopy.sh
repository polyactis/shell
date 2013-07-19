#!/bin/bash

source ~/.bash_profile


if test $# -lt 2; then
	echo "Usage:"
	echo "  $0 SOURCE DESTINATION ToggleRecursive"
	echo ""
	echo "Note:"
	echo "	#. This program restart the globus-url-copy if it exits non-zero (fail for whatever reason)."
	echo "	#. Append a star wildcard (*) to SOURCE."
	echo "	#. Always append a slash to DESTINATION."
	echo "	#. ToggleRecursive: recursive running means if any error other than Permission Denied is encountered, the script would call itself again."
	echo "	#. 	Set it to 1 to enable this recursive mode."
	echo
	echo "Examples:"
	echo "	# non-recursive"
	echo "	$0 gsiftp://grid4.hoffman2.idre.ucla.edu/u/home/eeskin/namtran/[0-9a-zA-Z]* file:///h0/namtran/"
	echo ""
	echo "	# Recursive"
	echo "	$0 gsiftp://grid4.hoffman2.idre.ucla.edu/u/home/eeskin/namtran/[0-9a-zA-Z]* file:///h0/namtran/ 1"
	echo
	echo
	exit 1
fi
#for shell debug purpose (display every commandline before it is executed)
set -vx
sourceDir=$1
destinationDir=$2
toggleRecursive=$3
if test -z $toggleRecursive; then
	toggleRecursive=0;	#default is 0
fi
echo toggleRecursive = $toggleRecursive

globusURLCopyPath=`which globus-url-copy`
commandLine="$globusURLCopyPath -sync-level 2 -sync -p 40 -vb -r $sourceDir $destinationDir"
echo commandLine is $commandLine

stderrFname=/tmp/stderr`python -c "import time; print time.time();"`
echo "stderr will be directed to $stderrFname"
`which touch` $stderrFname
touchExitCode=$?
if test $touchExitCode -eq 0; then
	echo "$stderrFname is writable."
else
	echo "Error: Could not write to $stderrFname"
	exit 1
fi
#catch the stderr for later checking
date | tee -a $stderrFname
echo $commandLine | tee -a $stderrFname
#$commandLine 2>&1 | tee -a $stderrFname
$commandLine 2>> $stderrFname
exitCode=$?
grep "Permission denied" $stderrFname
grepExitCode=$?
date
if test $exitCode -ne 0 && test $toggleRecursive -eq 1 ; then
	#cat $stderrFname
	if test $grepExitCode -ne 0 ; then
		#keep going if it's not Permission denied error
		echo "Re-run this program ..."
		bash $0 $sourceDir $destinationDir
	else
		echo "Exit as permission denied is encountered."
		exit $exitCode
	fi
else
	echo "Exit code is $exitCode. toggleRecursive is $toggleRecursive. Exits with zero code."
	exit 0
fi
