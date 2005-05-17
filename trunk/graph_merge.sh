#!/bin/sh

if test $# -ne 3
then
	echo "Usage:"
	echo "    graph_merge.sh SUPPORT SCHEMA TYPE"
	echo ""
	echo "a script calling graph_merge and complete_cor_vector.py."
	echo "TYPE 1 uses graph_merge.py, TYPE 2 uses graph_merge_lam.py"
	echo "TYPE 3 skips graph_merge"
	echo
	exit
fi

support=$1
schema=$2
type=$3

#the python library path
source ~/.bash_profile
merge_graph_file=~/bin/hhu_clustering/data/input/$schema\_$support
merge_graph_cor=~/bin/hhu_clustering/data/input/$schema\_$support.cor_vector
merge_graph_sig=~/bin/hhu_clustering/data/input/$schema\_$support.sig_vector
graph_dir=~/gph_result/$schema\_gspan/
dataset_dir=~/datasets/$schema/
date

echo ##### I. generate the summary graph ####
case "$type" in
	1)	echo ~/script/annot/bin/graph_merge.py -s $support $graph_dir $merge_graph_file
	~/script/annot/bin/graph_merge.py -s $support $graph_dir $merge_graph_file;;
	2)	echo mpirun.lam N ~/script/annot/bin/graph_merge_lam.py -s $support $graph_dir $merge_graph_file
		mpirun.lam N ~/script/annot/bin/graph_merge_lam.py -s $support $graph_dir $merge_graph_file;;
	3)	echo "graph_merge skipped";;
	*)	echo "TYPE" $type "not supported"
		exit 2;;
esac

echo
echo ##### II. generate cor_vector and sig_vector files ####
echo mpirun.lam N ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir
mpirun.lam N ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir

echo ##### III. transform gspan format into matrix format ####
echo ~/script/shell/clustering_test.sh $merge_graph_file
~/script/shell/clustering_test.sh $merge_graph_file

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

echo #####IV. Dumping cor_vector and sig_vector to database###
echo ~/script/annot/bin/codense/haiyan_cor_vector2db.py -c -k $schema -p ~/bin/hhu_clustering/$gene_id2no -i $merge_graph_cor -s $merge_graph_sig
~/script/annot/bin/codense/haiyan_cor_vector2db.py -c -k $schema -p ~/bin/hhu_clustering/$gene_id2no -i $merge_graph_cor -s $merge_graph_sig

date
