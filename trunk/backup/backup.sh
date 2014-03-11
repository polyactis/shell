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
localFolder=/usr/local/src/
if test -z "$host_name"
then
	host_name=hpc-cmb.usc.edu
fi
echo "tar -cf $localFolder/$tarFileName.tar $inputFolder"
tar -cf $localFolder/$tarFileName.tar $inputFolder
echo "gzip $localFolder/$tarFileName.tar"
gzip $localFolder/$tarFileName.tar
echo "scp $localFolder/$tarFileName.tar.gz yuhuang@$host_name:./backup/"
scp $localFolder/$tarFileName.tar.gz yuhuang@$host_name:./backup/
echo "rm $localFolder/$tarFileName.tar.gz"
rm $localFolder/$tarFileName.tar.gz
echo 'done'
date
}
backupFunc $*
