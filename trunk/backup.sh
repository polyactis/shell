#!/bin/sh
#argv[1] is the path for the directory.
#argv[2] is the name of the tar file.
date
echo -n 'Starting to backup ...'
tar -cvvf /usr/local/src/zip/$2.tar $1
gzip /usr/local/src/zip/$2.tar
scp /usr/local/src/zip/$2.tar.gz yuhuang@hto-g.usc.edu:.
rm /usr/local/src/zip/$2.tar.gz
echo 'done'
date
