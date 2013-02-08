#!/bin/sh


if test $# -ne 2
then
	echo "Usage:"
	echo "    graph_merge_lam.sh SUPPORT SCHEMA"
	echo ""
	echo "a script calling graph_merge_lam.py and complete_cor_vector.py."
	echo "merge_graph_file's name is graph_merge_lam.sh's + _2"
	echo
	exit
fi

support=$1
schema=$2
#the python library path
source ~/.bash_profile
merge_graph_file=~/bin/hhu_clustering/data/input/$schema\_$support\_2
merge_graph_cor=~/bin/hhu_clustering/data/input/$schema\_$support\_2.cor_vector
merge_graph_sig=~/bin/hhu_clustering/data/input/$schema\_$support\_2.sig_vector
graph_dir=~/gph_result/$schema\_gspan/
dataset_dir=~/datasets/$schema/

date

echo mpirun.lam n0-9 ~/script/annot/bin/graph_merge_lam.py -s $support $graph_dir $merge_graph_file
mpirun.lam n0-9 ~/script/annot/bin/graph_merge_lam.py -s $support $graph_dir $merge_graph_file

echo
echo ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir
~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir
date
