#!/bin/sh

if test $# -ne 3
then
	echo "Usage:"
	echo "    SchemaPreSetup.sh ORGANISM SCHEMA RUNCODE"
	echo
	echo "This is a script to setup go functions and gene table."
	echo
	echo "RUNCODE controls which part to turn on:"
	echo "	1.gene_table.py 2.find_unknown_genes.py"
	echo "	3.go_informative_node.py 4.go_bioprocess.py"
	echo "	5.gene_go_functions.py 6.graph_reorganize.py"
	echo "	7.prepare_gene_id2no.py"
	echo
	echo "1st digit(gene_table.py):1. union 2.intersection"
	exit
fi

organism=$1
schema=$2
runcode=$3
#05-21-05 use runcode to control which step is necessary
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`
type_5=`echo $runcode|awk '{print substr($0,5,1)}'`
type_6=`echo $runcode|awk '{print substr($0,6,1)}'`
type_7=`echo $runcode|awk '{print substr($0,7,1)}'`


unknown_file=/tmp/$organism.unknown
go_file=/tmp/$schema.go
datasets_dir=~/datasets/$schema
gph_dir=~/gph_result/$schema
gph_dir_gspan=~/gph_result/$schema\_gspan

#the python library path
source ~/.bash_profile
date
case "$type_1" in
	1)	echo ~/script/annot/bin/gene_table.py -k $schema -g $organism -c -u $datasets_dir
		~/script/annot/bin/gene_table.py -k $schema -g $organism -c -u $datasets_dir;;
	2)	echo ~/script/annot/bin/gene_table.py -k $schema -g $organism -c $datasets_dir
		~/script/annot/bin/gene_table.py -k $schema -g $organism -c $datasets_dir;;
	*)	echo "gene_table.py skipped";;
esac

if [ $type_2 = "1" ]; then
	echo ~/script/annot/bin/find_unknown_genes.py -g $organism $unknown_file
	~/script/annot/bin/find_unknown_genes.py -g $organism $unknown_file
fi

if [ $type_3 = "1" ]; then
	echo ~/script/annot/bin/GO/go_informative_node.py -k $schema -b \>$go_file
	~/script/annot/bin/GO/go_informative_node.py -k $schema -b >$go_file
fi

if [ $type_4 = "1" ]; then
	echo ~/script/annot/bin/go_bioprocess.py -k $schema -p min -u $unknown_file -c $go_file
	~/script/annot/bin/go_bioprocess.py -k $schema -p min -u $unknown_file -c $go_file
fi

if [ $type_5 = "1" ]; then
	echo ~/script/annot/bin/gene_go_functions.py -k $schema -c
	~/script/annot/bin/gene_go_functions.py -k $schema -c
fi

if [ $type_6 = "1" ]; then
	#05-20-05 add graph_reorganize.py
	echo ~/script/annot/bin/graph_reorganize.py -k $schema -t1 -g $organism $gph_dir $gph_dir_gspan 
	~/script/annot/bin/graph_reorganize.py -k $schema -t1 -g $organism $gph_dir $gph_dir_gspan 
fi

if [ $type_7 = "1" ]; then
	#05-20-05 add prepare_gene_id2no.py
	gene_id2no=$schema\_gene_id2no
	echo ~/script/annot/bin/prepare_gene_id2no.py -k $schema ~/bin/hhu_clustering/$gene_id2no
	~/script/annot/bin/prepare_gene_id2no.py -k $schema ~/bin/hhu_clustering/$gene_id2no
fi

date
