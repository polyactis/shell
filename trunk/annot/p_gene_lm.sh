#!/bin/sh
if test $# -ne 4
then
	echo "Usage:"
	echo "    p_gene_lm.sh SCHEMA INPUT_FILE LM_BIT ACC_CUTOFF"
	echo "	For LM_BIT, see p_gene_lm.py doc"
	echo "This is a script calling p_gene_lm.py."
	echo "  wrap it in a shell script because it can't run directly"
	echo "  through qsub, and but it needs ~/.bash_profile"
	exit
fi
schema=$1
input_file=$2
lm_bit=$3
acc_cutoff=$4

splat_result_table=splat_$2
mcl_result_table=mcl_$2
cluster_stat_table=/scratch/00/yuhuang/cluster_stat/cluster_$2
p_gene_table=p_gene_$2_e5
acc_int=`echo $acc_cutoff|awk '{print $0*100}'`
if [ $lm_bit = "111" ]; then
	lm_suffix=$input_file\_e5_a$acc_int	#backward compatible
else
	lm_suffix=$input_file\_e5_$lm_bit\a$acc_int
fi
lm_table=lm_$lm_suffix
gene_p_table=gene_p_$lm_suffix

#the python library path
source ~/.bash_profile
date
echo ~/script/annot/bin/p_gene_lm.py -k $schema -t $p_gene_table -s $splat_result_table -m $mcl_result_table -l $lm_table -o -j2 -c -b $lm_bit -a $acc_cutoff -n
~/script/annot/bin/p_gene_lm.py -k $schema -t $p_gene_table -s $splat_result_table -m $mcl_result_table -l $lm_table -o -j2 -c -b $lm_bit -a $acc_cutoff -n
date
