#!/bin/sh

if test $# -ne 3
then
	echo "Usage:"
	echo "    graph_merge.sh SUPPORT SCHEMA RUNCODE"
	echo ""
	echo "a script calling graph_merge and complete_cor_vector.py."
	echo
	echo "RUNCODE is something like 1010, or 2110"
	echo "	The four digits correspond to "
	echo "	1.graph_merge, 2.complete_cor_vector,"
	echo "	3.clustering_test, 4.haiyan_cor_vector2db."
	echo "1 means enable, 0 means disable"
	echo
	echo "For graph_merge,"
	echo "  1 graph_merge.py, 2 graph_merge_lam.py(10 from hostfile)"
	echo "  3 graph_merge_lam.py(nodes assigned by qsub)"
	echo
	echo "For complete_cor_vector,"
	echo "  1 gph_dir to get corCut(10 from hostfile)"
	echo "  2 gph_dir to get corCut(nodes assigned by qsub), 3 t-dist's p-value 0.01"
	echo
	exit
fi

support=$1
schema=$2
runcode=$3
#05-21-05 use runcode to control which step is necessary
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`

#the python library path
source ~/.bash_profile
merge_graph_file=~/bin/hhu_clustering/data/input/$schema\_$support
merge_graph_cor=~/bin/hhu_clustering/data/input/$schema\_$support.cor_vector
merge_graph_sig=~/bin/hhu_clustering/data/input/$schema\_$support.sig_vector
graph_dir=~/gph_result/$schema\_gspan/
dataset_dir=~/datasets/$schema/
raw_graph_dir=~/gph_result/$schema/
date

echo ##### I. generate the summary graph ####
case "$type_1" in
	1)	echo ~/script/annot/bin/graph_merge.py -s $support $graph_dir $merge_graph_file
		~/script/annot/bin/graph_merge.py -s $support $graph_dir $merge_graph_file;;
	2)	echo mpirun.mpich -np 10 -machinefile ~/hostfile ~/script/annot/bin/graph_merge_lam.py -s $support $graph_dir $merge_graph_file
		mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/graph_merge_lam.py -s $support $graph_dir $merge_graph_file;;
	3)	echo mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/graph_merge_lam.py -s $support $graph_dir $merge_graph_file
		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/graph_merge_lam.py -s $support $graph_dir $merge_graph_file;;
	*)	echo "graph_merge skipped";;
esac

echo

echo ##### II. generate cor_vector and sig_vector files ####
case "$type_2" in
	#echo mpirun.lam N ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir
	#mpirun.lam N ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir
	1)	echo mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -p 0 -c 0 -g $raw_graph_dir -s $merge_graph_sig $dataset_dir
	mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -p 0 -c 0 -g $raw_graph_dir -s $merge_graph_sig $dataset_dir;;
	2)	echo mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -p 0 -c 0 -g $raw_graph_dir -s $merge_graph_sig $dataset_dir
		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -p 0 -c 0 -g $raw_graph_dir -s $merge_graph_sig $dataset_dir;;
	3)	echo mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir
		mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/graph/complete_cor_vector.py -i $merge_graph_file -o $merge_graph_cor -s $merge_graph_sig $dataset_dir;;
	*)	echo "complete_cor_vector.py skipped";;
esac

if [ $type_3 = "1" ]; then
	echo ##### III. transform gspan format into matrix format ####
	echo ~/script/shell/clustering_test.sh $merge_graph_file
	~/script/shell/clustering_test.sh $merge_graph_file
fi

#05-20-05 no more schema guessing

#case "$schema" in
#	sc_new_38)	gene_id2no=sc_54_6661_gene_id2no
#		echo $gene_id2no;;
#	sc_54_6661)	gene_id2no=sc_54_6661_gene_id2no
#		echo $gene_id2no;;
#	mm_79)	gene_id2no="mm_79_gene_id2no"
#		echo $gene_id2no;;
#	mm_73)	gene_id2no="mm_73_gene_id2no"
#		echo $gene_id2no;;
#	*)	echo "Schema" $schema "not supported"
#		exit 2;;
#esac
if [ $type_4 = "1" ]; then
	gene_id2no=$schema\_gene_id2no
	echo #####IV. Dumping cor_vector and sig_vector to database###
	echo ~/script/annot/bin/codense/haiyan_cor_vector2db.py -c -k $schema -p ~/bin/hhu_clustering/$gene_id2no -i $merge_graph_cor -s $merge_graph_sig
	~/script/annot/bin/codense/haiyan_cor_vector2db.py -c -k $schema -p ~/bin/hhu_clustering/$gene_id2no -i $merge_graph_cor -s $merge_graph_sig
fi

date
