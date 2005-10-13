#!/bin/sh
#$ -pe mpich 5

if test $# -ne 4
then
	echo "Usage: mpibs_stat.sh SCHEMA INPUT_FILE LM_BIT ACC_CUTOFF"
	echo
	echo "wrapper of MpiClusterBsStat.py(mpi operative embedded, ssh itself)"
	exit
fi

schema=$1
input_file=$2
lm_bit=$3
acc_cutoff=$4
mcl_table=mcl_$input_file
p_gene_table=p_gene_$input_file\_e5
acc_int=`echo $acc_cutoff|awk '{print $0*100}'`
if [ $lm_bit = "111" ]; then
	lm_suffix=$input_file\_e5_a$acc_int	#backward compatible
else
	lm_suffix=$input_file\_e5_$lm_bit\a$acc_int
fi
lm_table=lm_$lm_suffix
gene_p_table=gene_p_$lm_suffix
good_cluster_table=good_cl_$lm_suffix
cluster_bs_table=cluster_bs_$lm_suffix

n_hosts=$NHOSTS
machinefile=$TMPDIR/machines
cp $machinefile ~/
date
echo ssh $HOSTNAME mpirun -np $n_hosts -machinefile ~/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $good_cluster_table -l  $cluster_bs_table -c -n
ssh $HOSTNAME mpirun -np $n_hosts -machinefile ~/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $good_cluster_table -l  $cluster_bs_table -c -n

date

