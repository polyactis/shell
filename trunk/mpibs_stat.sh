#!/bin/sh
#$ -pe mpich 5

if test $# -lt 3
then
	echo "Usage: mpibs_stat.sh SCHEMA INPUT_FILE ACC_CUTOFF"
	echo
	echo "wrapper of MpiClusterBsStat.py(mpi operative embedded, ssh itself)"
	exit
fi

schema=$1
input_file=$2
acc_cutoff=$3
acc_int=`echo $acc_cutoff|awk '{print $0*100}'`
mcl_table=mcl_$input_file
p_gene_table=p_gene_$input_file\_e5
gene_p_table=gene_p_$input_file\_e5_a$acc_int
good_cluster_table=good_cl_$input_file\_e5_a$acc_int
cluster_bs_table=cluster_bs_$input_file\_e5_a$acc_int

n_hosts=$NHOSTS
machinefile=$TMPDIR/machines
cp $machinefile ~/
date
echo ssh $HOSTNAME mpirun -np $n_hosts -machinefile ~/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $good_cluster_table -l  $cluster_bs_table -c -n
ssh $HOSTNAME mpirun -np $n_hosts -machinefile ~/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $good_cluster_table -l  $cluster_bs_table -c -n

date

