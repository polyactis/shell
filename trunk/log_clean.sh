#!/bin/sh

cd /var/log/

for i in $(ls)
do
	if test -w $i
	then 
		if test -d $i
		then
			echo $i is a directory.
			
		else
			echo $i is cleaved to zero size.
			cat '' >$i
		fi
	fi
done

cd /var/log/ksymoops/

rm * -f
