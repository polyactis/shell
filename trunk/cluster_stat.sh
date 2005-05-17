#!/bin/sh

if test $# -ne 4
then
	echo "Usage:"
	echo "    cluster_stat.sh SCHEMA INPUT_FILE ORGANISM COPATH_FLAG"
	echo ""
	echo "COPATH_FLAG is 1(copath) or 2(codense), 3(biclustering)"
	echo
	echo "This is a script linking all stat programs"
	echo "Ignore ORGANISM(05-16-05)"
	exit
fi

schema=$1
input_file=$2
organism=$3
codenOrcopath=$4
#1 is copath
#2 is coden
splat_result_table=splat_$2
mcl_result_table=mcl_$2
cluster_stat_table=cluster_$2
p_gene_table=p_gene_$2_e5
gene_p_table=gene_p_$2_e5_p01

case "$schema" in
	sc_new_38)	gene_id2no=sc_54_6661_gene_id2no
		echo $gene_id2no;;
	sc_54_6661)	gene_id2no=sc_54_6661_gene_id2no
		echo $gene_id2no;;
	mm_79)	gene_id2no="mm_79_gene_id2no"
		echo $gene_id2no;;
	mm_73)	gene_id2no="mm_73_gene_id2no"
		echo $gene_id2no;;
	*)	echo "Schema" $schema "not supported"
		exit 2;;
esac


#the python library path
source ~/.bash_profile
date
cd ~/bin/hhu_clustering/data/output/netmine/

if [ $codenOrcopath = "3" ]
then
	echo ~/script/annot/bin/codense/codense2db.py -k $1 -c -t $splat_result_table -m $mcl_result_table $2
	~/script/annot/bin/codense/codense2db.py -k $1 -c -t $splat_result_table -m $mcl_result_table $2
	else
	echo ~/script/annot/bin/codense/codense2db.py -k $1 -p ~/bin/hhu_clustering/$gene_id2no -c -y$4 -t $splat_result_table -m $mcl_result_table $2
	~/script/annot/bin/codense/codense2db.py -k $1 -p ~/bin/hhu_clustering/$gene_id2no -c -y$4 -t $splat_result_table -m $mcl_result_table $2
fi

echo ~/script/annot/bin/cluster_stat.py -k $1 -s $mcl_result_table  -t $cluster_stat_table -b -w -c
~/script/annot/bin/cluster_stat.py -k $1 -s $mcl_result_table  -t $cluster_stat_table -b -w -c
echo ~/script/annot/bin/gene_stat.py -k $1 -t $cluster_stat_table -m $mcl_result_table -g $p_gene_table -e 5 -l -w -c
~/script/annot/bin/gene_stat.py -k $1 -t $cluster_stat_table -m $mcl_result_table -g $p_gene_table -e 5 -l -w -c
echo ~/script/annot/bin/p_gene_analysis.py -k $1 -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
~/script/annot/bin/p_gene_analysis.py -k $1 -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
echo ~/script/annot/bin/gene_p_map_redundancy.py -k $1 -t $p_gene_table -n $gene_p_table -c
~/script/annot/bin/gene_p_map_redundancy.py -k $1 -t $p_gene_table -n $gene_p_table -c
echo ~/script/annot/bin/connectivity_original.py -k $1 -c -t $mcl_result_table
~/script/annot/bin/connectivity_original.py -k $1 -c -t $mcl_result_table
date
