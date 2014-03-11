#!/bin/sh
date
backupHostnameDefault=hpc-cmb.usc.edu
localFolder=/usr/local/src/
if test $# -lt 1 ; then
	echo "  $0 dbname [backupHostname] [dbuser]"
	echo ""
	echo "Note:"
	echo "	dbname is the database to be backed-up."
	echo "	backupHostname is the hostname of the machine where backup is to be sent through scp. Default is $backupHostnameDefault."
	echo "Examples:"
	echo "	$0 vervetdb hpc-cmb.usc.edu yh"
	echo "	$0 vervetdb"
	exit 1
fi

echo -n 'Starting to dump the '
echo -n $1
echo -n ' ...'
dbname=$1
if test -n "$2"
then
	host_name=$2
else
	host_name=$backupHostnameDefault
fi
dbuser=$3
if test -n "$dbuser"
then
	dbuserArgument="-U $dbuser"
else
	dbuserArgument=""
fi
pg_dump $dbuserArgument $dbname |gzip >$localFolder/$dbname.gz
scp $localFolder/$dbname.gz yuhuang@$host_name:./backup/
rm $localFolder/$dbname.gz
echo -n 'done'
date
