#!/bin/sh
date
schema=$1
splat_table=$2
mcl_table=$3
cluster_table=$4
mcl_table2=$5
cluster_table2=$6
echo $schema $splat_table $mcl_table $cluster_table $mcl_table2 $cluster_table2
echo "Third stage pruning"
~/script/annot/bin/cluster_prune.py -k $schema -c -p 2 -s $mcl_table -t $mcl_table2
echo "Done"
echo "mcl_result_stat2"
~/script/annot/bin/mcl_result_stat.py -k $schema -c -t $mcl_table2
echo "Done"
echo "gene_stat_on_mcl_result2"
~/script/annot/bin/gene_stat_on_mcl_result.py -k $schema -p 0.001 -m $mcl_table2
echo "Done"
echo "cluster_stat2"
~/script/annot/bin/cluster_stat.py -k $schema -c -s $mcl_table2 -t $cluster_table2 -b
echo "Done"
echo "gene_stat"
~/script/annot/bin/gene_stat.py -k $schema -p 0.001 -w -t $cluster_table2 -m $mcl_table2
echo "Done"
date
