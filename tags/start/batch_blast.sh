#!/bin/sh
cd ~/at_seq_to_blast

for i in $(ls )
do
	if test -r $i
	then
		echo $i
		/usr/local/src/zip/netblast/blastcl3 -p blastn -n T -m 7 -d genomes/ara -i $i -o ~/blast_result/$i\.xml
	fi
done
