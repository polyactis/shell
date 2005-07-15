#!/bin/sh
#split the sequence file of arabidopsis (fasta format) into pieces and blast them against NCBI
#the reason to split is that blastcl3 can't deal with file with many sequences, it'll skip some of them.

echo "Make directories, at_seq_to_blast and blast_result"
mkdir ~/at_seq_to_blast
mkdir ~/blast_result
cd ~/at_seq_to_blast

echo "Splitting sequence files into pieces"
split -a 3 -l 44 ~/unigene_linking/at_probeset_seq

echo "Start to blast"
for i in $(ls )
do
	if test -r $i
	then
		echo $i
		/usr/local/src/zip/netblast/blastcl3 -p blastn -n T -m 7 -d genomes/ara -i $i -o ~/blast_result/$i\.xml
	fi
done
