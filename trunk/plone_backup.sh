#!/bin/sh
backupHostnameDefault=hpc-cmb.usc.edu
if test $# -lt 1 ; then
	echo "  $0 ploneFolder [backupHostname]"
	echo ""
	echo "Note:"
	echo "	ploneFolder is the path to the top plone folder."
	echo "	backupHostname is the hostname of the machine where backup is to be sent through scp. Default is $backupHostnameDefault."
	echo "Examples:"
	echo "	$0 /usr/local/Plone-4.0.4/"
	exit 1
fi
date
ploneFolder=$1
backupHostname=$2
echo -n 'Starting to backup '
echo ' $ploneFolder  ...'
if test -z "$backupHostname"
then
	backupHostname=$backupHostnameDefault
fi
echo "backup host is $backupHostname."
backupProgram=$ploneFolder/zeocluster/bin/backup
#2012.1.4 run the backup program
$backupProgram
backupLocalPath=$ploneFolder/zeocluster/var/backups/

shellDir=`dirname $0`
$shellDir/backup.sh $backupLocalPath uclaOfficePloneBackup $backupHostname


