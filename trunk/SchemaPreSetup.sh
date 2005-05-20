#!/bin/sh

if test $# -ne 2
then
	echo "Usage:"
	echo "    SchemaPreSetup.sh ORGANISM SCHEMA"
	echo
	echo "This is a script to setup go functions and gene table."
	exit
fi

organism=$1
schema=$2
unknown_file=/tmp/$organism.unknown
go_file=/tmp/$schema.go
datasets_dir=~/datasets/$schema

#the python library path
source ~/.bash_profile
date
#05-20-05 add gene_table.py, take the union form
echo ~/script/annot/bin/gene_table.py -k $schema -g $organism -u -c $datasets_dir
~/script/annot/bin/gene_table.py -k $schema -g $organism -u -c $datasets_dir

echo ~/script/annot/bin/find_unknown_genes.py -g $organism $unknown_file
~/script/annot/bin/find_unknown_genes.py -g $organism $unknown_file

echo ~/script/annot/bin/GO/go_informative_node.py -k $schema -b \>$go_file
~/script/annot/bin/GO/go_informative_node.py -k $schema -b >$go_file

echo ~/script/annot/bin/go_bioprocess.py -k $schema -p min -u $unknown_file -c $go_file
~/script/annot/bin/go_bioprocess.py -k $schema -p min -u $unknown_file -c $go_file

echo ~/script/annot/bin/gene_go_functions.py -k $schema -c
~/script/annot/bin/gene_go_functions.py -k $schema -c

date
