#!/bin/sh

if test $# -ne 5
then
	echo "Usage:"
	echo "    SchemaPreSetup.sh ORGANISM SCHEMA GENE_FREQ DEPTH_CUTOFF RUNCODE"
	echo
	echo "This is a script to setup go functions and gene table."
	echo
	echo "RUNCODE controls which part to turn on:"
	echo "	1.gene_table.py 2.find_unknown_genes.py"
	echo "	3.go_informative_node.py 4.go_bioprocess.py"
	echo "	5.gene_go_functions.py 6.graph_reorganize.py"
	echo "	7.prepare_gene_id2no.py 8.fill_dataset_no2id.py"
	echo
	echo "  3rd digit: 1(node_type=1), 2(node_type=5)"
	exit
fi

organism=$1
schema=$2
gene_freq=$3
depth_cutoff=$4
runcode=$5
#05-21-05 use runcode to control which step is necessary
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`
type_5=`echo $runcode|awk '{print substr($0,5,1)}'`
type_6=`echo $runcode|awk '{print substr($0,6,1)}'`
type_7=`echo $runcode|awk '{print substr($0,7,1)}'`
type_8=`echo $runcode|awk '{print substr($0,8,1)}'`


unknown_file=/tmp/$organism.unknown
go_file=/tmp/$schema.go
datasets_dir=~/datasets/$schema
gph_dir=~/gph_result/$schema
gph_dir_gspan=~/gph_result/$schema\_gspan

check_exit_status() {
	date
	return_code=$?
	if [ $return_code != "0" ]; then
		echo "Return code non-zero:"$return_code
		exit
	fi
}
#the python library path
source ~/.bash_profile
date
case "$type_1" in
	1)	echo ~/script/annot/bin/gene_table.py -k $schema -g $organism -c -m $gene_freq $datasets_dir
		~/script/annot/bin/gene_table.py -k $schema -g $organism -c -m $gene_freq $datasets_dir;;
	*)	echo "gene_table.py skipped";;
esac

check_exit_status

if [ $type_2 = "1" ]; then
	echo ~/script/annot/bin/find_unknown_genes.py -g $organism $unknown_file
	~/script/annot/bin/find_unknown_genes.py -g $organism $unknown_file
fi

check_exit_status

case "$type_3" in 
	1)	echo ~/script/annot/bin/GO/go_informative_node.py -k $schema -b \>$go_file
		~/script/annot/bin/GO/go_informative_node.py -k $schema -b >$go_file;;
	2)	echo ~/script/annot/bin/GO/go_informative_node.py -k $schema -b -s 5 -m 160 -n5 -l $depth_cutoff \>$go_file
		~/script/annot/bin/GO/go_informative_node.py -k $schema -b -s 5 -m 160 -n5 -l $depth_cutoff >$go_file;;
	*)	echo "go_informative_node.py skipped";;
esac

check_exit_status

if [ $type_4 = "1" ]; then
	echo ~/script/annot/bin/go_bioprocess.py -k $schema -p min -u $unknown_file -c $go_file
	~/script/annot/bin/go_bioprocess.py -k $schema -p min -u $unknown_file -c $go_file
fi

check_exit_status

if [ $type_5 = "1" ]; then
	echo ~/script/annot/bin/gene_go_functions.py -k $schema -c
	~/script/annot/bin/gene_go_functions.py -k $schema -c
fi

check_exit_status

if [ $type_6 = "1" ]; then
	#05-20-05 add graph_reorganize.py
	echo ~/script/annot/bin/graph_reorganize.py -k $schema -t1 -g $organism $gph_dir $gph_dir_gspan 
	~/script/annot/bin/graph_reorganize.py -k $schema -t1 -g $organism $gph_dir $gph_dir_gspan 
fi

check_exit_status

if [ $type_7 = "1" ]; then
	#05-20-05 add prepare_gene_id2no.py
	gene_id2no=$schema\_gene_id2no
	echo ~/script/annot/bin/prepare_gene_id2no.py -k $schema ~/bin/hhu_clustering/$gene_id2no
	~/script/annot/bin/prepare_gene_id2no.py -k $schema ~/bin/hhu_clustering/$gene_id2no
fi

check_exit_status

if [ $type_8 = "1" ]; then
	#12-24-05 assume the mapping_file
	mapping_file=~/mapping/$schema\_datasets_mapping
	echo ~/script/annot/bin/fill_dataset_no2id.py -k $schema -m $mapping_file -c
	~/script/annot/bin/fill_dataset_no2id.py -k $schema -m $mapping_file -c
fi

check_exit_status
