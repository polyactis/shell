#!/bin/sh
backupHostnameDefault=hpc-cmb.usc.edu
ploneSubFolderDefault=zeocluster
if test $# -lt 1 ; then
	echo "  $0 ploneFolder [backupHostname] [ploneSubFolder]"
	echo ""
	echo "Note:"
	echo "	ploneFolder is the path to the top plone folder."
	echo "	backupHostname is the hostname of the machine where backup is to be sent through scp. Default is $backupHostnameDefault."
	echo "	ploneSubFolder is the subfolder of ploneFolder, in which the plone instance or zeo cluster instance is installed. Default is $ploneSubFolderDefault."
	echo "Examples:"
	echo "	$0 /usr/local/Plone-4.0.4/"
	echo "	$0 /usr/local/Plone-4.1.5/ hpc-cmb.usc.edu zinstance"
	exit 1
fi
date
ploneFolder=$1
backupHostname=$2
ploneSubFolder=$3
echo -n 'Starting to backup '
echo ' $ploneFolder/$ploneSubFolder  ...'
if test -z "$backupHostname"
then
	backupHostname=$backupHostnameDefault
fi
if test -z "$ploneSubFolder"
then
	ploneSubFolder=$ploneSubFolderDefault
fi
echo "backup host is $backupHostname."
backupProgram=$ploneFolder/$ploneSubFolder/bin/backup
#2012.1.4 run the backup program
shellDir=`dirname $0`
$backupProgram
backupLocalPath=$ploneFolder/$ploneSubFolder/var/backups/
$shellDir/backup.sh $backupLocalPath uclaOfficePloneBackup $backupHostname

blobBackupLocalPath=$ploneFolder/$ploneSubFolder/var/blobstoragebackups
$shellDir/backup.sh $blobBackupLocalPath uclaOfficePloneBlobBackup $backupHostname
