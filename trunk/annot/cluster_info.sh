#!/bin/sh

if test $# -ne 2
then
	echo "Usage:"
	echo "    cluster_info.sh SCHEMA INPUT_FILE"
	echo ""
	echo "a script calling cluster_info.py to output darwin array for jasmine."
	echo
	exit
fi

schema=$1
input_file=$2

splat_result_table=splat_$2
mcl_result_table=mcl_$2
cluster_stat_table=cluster_$2
p_gene_table=p_gene_$2_e5
gene_p_table=gene_p_$2_e5_p01


#the python library path
source ~/.bash_profile
date

echo ~/script/annot/bin/cluster_info.py -k $schema -t $splat_result_table -m $mcl_result_table ~/cluster_info/$schema.$mcl_result_table.darwin
~/script/annot/bin/cluster_info.py -k $schema -t $splat_result_table -m $mcl_result_table ~/cluster_info/$schema.$mcl_result_table.darwin

date
