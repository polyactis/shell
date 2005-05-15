#!/bin/sh

if test $# -ne 2
then
	echo "Usage:"
	echo "    graph_merge.sh SUPPORT SCHEMA"
	echo ""
	echo "a script calling graph_merge.py and complete_cor_vector.py."
	echo
	exit
fi

support=$1
schema=$2
#the python library path
source ~/.bash_profile
merge_graph_file=~/bin/hhu_clustering/data/input/$schema\_$support
merge_graph_cor=~/bin/hhu_clustering/data/input/$schema\_$support.cor_vector
merge_graph_sig=~/bin/hhu_clustering/data/input/$schema\_$support.sig_vector
graph_dir=~/gph_result/$schema\_gspan/
dataset_dir=~/datasets/$schema/
date

echo ~/script/annot/bin/graph_merge.py -s $support $graph_dir $merge_graph_file
~/script/annot/bin/graph_merge.py -s $support $graph_dir $merge_graph_file

echo
echo ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir
~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir

date
