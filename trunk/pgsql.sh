#!/bin/sh
ps -ef
date
echo -n 'Starting to dump the '
echo -n $1
echo -n ' ...'
pg_dump $1 |gzip >/usr/local/src/zip/$1.gz
scp /usr/local/src/zip/$1.gz yuhuang@hto-g.usc.edu:./backup/
rm /usr/local/src/zip/$1.gz
echo -n 'done'
date
