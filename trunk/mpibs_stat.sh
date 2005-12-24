#!/bin/sh
#$ -pe mpich 5

if test $# -lt 4
then
	echo "Usage: mpibs_stat.sh SCHEMA INPUT_FILE LM_BIT ACC_CUTOFF cluster_bs_table PARAMETERS"
	echo
	echo "wrapper of MpiClusterBsStat.py(mpi operative embedded, ssh itself)"
	exit
fi

schema=$1
input_file=$2
lm_bit=$3
acc_cutoff=$4

#12-15-05
cluster_bs_table=$5
parameter=''
while test -n "$6"
do
parameter=$parameter' '$6
shift
done

pattern_table=pattern_$input_file

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
#cluster_bs_table=cluster_bs_$lm_suffix

#n_hosts=$NSLOTS
#machinefile=$TMPDIR/machines
#cp $machinefile ~/
date
#12-20-05 use pattern_table
echo mpiexec ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $pattern_table -l  $cluster_bs_table -c -n $parameter
mpiexec ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $pattern_table -l  $cluster_bs_table -c -n $parameter

#echo ssh $HOSTNAME mpirun -np $n_hosts -machinefile ~/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $good_cluster_table -l  $cluster_bs_table -c -n $parameter
#ssh $HOSTNAME mpirun -np $n_hosts -machinefile ~/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $good_cluster_table -l  $cluster_bs_table -c -n $parameter

date

