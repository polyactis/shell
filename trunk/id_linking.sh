#!/bin/sh
if test $# -ne 2 
then
	echo "Usage:"
	echo "    id_linking.sh organism organismU"
	echo 
	echo " organism is small case two-letter"
	echo " organismU is like At, Cel, Dm, Hs"
	echo " call MdbId2UnigeneId.py to link id to Unigene id."
	echo " first suid_info; then probe_information_center"
	echo " Gene and Unigene data files are in /scratch/00/yuhuang/tmp/"
	echo
	exit
fi

organism=$1
organismU=$2

#the python library path
source ~/.bash_profile
date

echo ~/script/microarray/bin/MdbId2UnigeneId.py -i suid_info -g $organism -p $organism\_unigene -o /scratch/00/yuhuang/tmp/gene_info -a /scratch/00/yuhuang/tmp/gene2accession -w /scratch/00/yuhuang/tmp/$organismU.data -x /scratch/00/yuhuang/tmp/$organismU.retired.lst -n -c
~/script/microarray/bin/MdbId2UnigeneId.py -i suid_info -g $organism -p $organism\_unigene -o /scratch/00/yuhuang/tmp/gene_info -a /scratch/00/yuhuang/tmp/gene2accession -w /scratch/00/yuhuang/tmp/$organismU.data -x /scratch/00/yuhuang/tmp/$organismU.retired.lst -n -c

date

echo ~/script/microarray/bin/MdbId2UnigeneId.py -i probe_information_center -g $organism -p $organism\_unigene -o /scratch/00/yuhuang/tmp/gene_info -a /scratch/00/yuhuang/tmp/gene2accession -w /scratch/00/yuhuang/tmp/$organismU.data -x /scratch/00/yuhuang/tmp/$organismU.retired.lst -c
~/script/microarray/bin/MdbId2UnigeneId.py -i probe_information_center -g $organism -p $organism\_unigene -o /scratch/00/yuhuang/tmp/gene_info -a /scratch/00/yuhuang/tmp/gene2accession -w /scratch/00/yuhuang/tmp/$organismU.data -x /scratch/00/yuhuang/tmp/$organismU.retired.lst -c

date
