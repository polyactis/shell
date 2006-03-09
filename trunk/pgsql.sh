#!/bin/sh
date
echo -n 'Starting to dump the '
echo -n $1
echo -n ' ...'
if test -n "$2"
then
	host_name=$2
else
	host_name=hpc-cmb.usc.edu
fi
pg_dump $1 |gzip >/usr/local/src/zip/$1.gz
scp /usr/local/src/zip/$1.gz yuhuang@$host_name:./backup/
rm /usr/local/src/zip/$1.gz
echo -n 'done'
date
