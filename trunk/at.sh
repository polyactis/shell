#!/bin/sh

date

#wget -c -nd  -r --retr-symlinks -P /usr/local/src/GEO/GDS ftp://ftp.ncbi.nih.gov/pub/geo/data/gds/soft_gz/
#wget -c -nd  -r  --retr-symlinks -P /usr/local/src/GEO/ ftp://ftp.ncbi.nih.gov/pub/geo/data/geo/by_platform/


#pg_dump microarraydb >/usr/local/src/zip/microarraydb
#echo "microarraydb dumped to /usr/local/src/zip/microarraydb"
#while [ 0 == 0 ] ;do
#	ps -ef|grep at.py >/dev/null
#	if [ $? == 1 ]; then
#		break
#	fi
#	sleep 15m
#done
#echo "human suid,cluterid,accession selection done"
echo 'Starting unigene linking for dm...'
/home/yh/script/microarray/bin/unigene_update.py dm /home/yh/dm_probeset1
#mv /tmp/dm_geo_good_result_file /home/yh/dm_good1
#mv /tmp/dm_geo_bad_result_file /home/yh/dm_bad1

#/home/yh/script/microarray/bin/smd_batch.py SC commit 
echo 'done'

date
