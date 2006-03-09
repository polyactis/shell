#!/bin/sh
#argv[1] is the path for the directory.
#argv[2] is the name of the tar file.
date
echo -n 'Starting to backup '
echo -n $1 
echo -n ' ...'
if test -n "$3"
then
	host_name=$3
else
	host_name=hpc-cmb.usc.edu
fi
tar -cvvf /usr/local/src/zip/$2.tar $1
gzip /usr/local/src/zip/$2.tar
scp /usr/local/src/zip/$2.tar.gz yuhuang@$host_name:./backup/
rm /usr/local/src/zip/$2.tar.gz
echo 'done'
date
