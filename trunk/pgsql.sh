#!/bin/sh
ps -ef
date
echo -n 'Starting to dump the microarraydb...'
pg_dump mdb |gzip >/usr/local/src/zip/microarraydb.gz
scp /usr/local/src/zip/microarraydb.gz yuhuang@hto-g.usc.edu:.
rm /usr/local/src/zip/microarraydb.gz
echo -n 'done'
date
