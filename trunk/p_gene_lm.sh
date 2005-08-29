#!/bin/sh
if test $# -ne 3
then
	echo "Usage:"
	echo "    p_gene_lm.sh SCHEMA INPUT_FILE ACC_CUTOFF"
	echo
	echo "This is a script calling p_gene_lm.py."
	echo "  wrap it in a shell script because it can't run directly"
	echo "  through qsub, and but it needs ~/.bash_profile"
	exit
fi
schema=$1
input_file=$2
acc_cutoff=$3

splat_result_table=splat_$2
mcl_result_table=mcl_$2
cluster_stat_table=/scratch/00/yuhuang/cluster_stat/cluster_$2
p_gene_table=p_gene_$2_e5
acc_int=`echo $acc_cutoff|awk '{print $0*100}'`
lm_table=lm_$2\_e5_a$acc_int
gene_p_table=gene_p_$2\_e5_a$acc_int

#the python library path
source ~/.bash_profile
date
echo ~/script/annot/bin/p_gene_lm.py -k $schema -t $p_gene_table -s $splat_result_table -m $mcl_result_table -l $lm_table -o -j2 -c -b 111 -a $acc_cutoff -n
~/script/annot/bin/p_gene_lm.py -k $schema -t $p_gene_table -s $splat_result_table -m $mcl_result_table -l $lm_table -o -j2 -c -b 111 -a $acc_cutoff -n
date
