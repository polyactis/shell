#!/bin/sh
#argv[1] is the path for the directory.
#argv[2] is the name of the tar file.
backupFunc () {
date
inputFolder=$1
echo -n 'Starting to backup '
echo -n $inputFolder
echo -n ' ...'
tarFileName=$2
host_name=$3
if test -z "$host_name"
then
	host_name=hpc-cmb.usc.edu
fi
echo "tar -cf /usr/local/src/zip/$tarFileName.tar $inputFolder"
tar -cf /usr/local/src/zip/$tarFileName.tar $inputFolder
echo "gzip /usr/local/src/zip/$tarFileName.tar"
gzip /usr/local/src/zip/$tarFileName.tar
echo "scp /usr/local/src/zip/$tarFileName.tar.gz yuhuang@$host_name:./backup/"
scp /usr/local/src/zip/$tarFileName.tar.gz yuhuang@$host_name:./backup/
echo "rm /usr/local/src/zip/$tarFileName.tar.gz"
rm /usr/local/src/zip/$tarFileName.tar.gz
echo 'done'
date
}
backupFunc $*
