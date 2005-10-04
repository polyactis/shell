#!/bin/sh
if test $# -lt 4
then
	echo "Usage:"
	echo "    filter.sh SCHEMA INPUT_FILE ACC_CUTOFF RUNCODE"
	echo
	echo "Gets the prediction clusters out and do tf analysis"
	echo
	echo "RUNCODE controls which part to turn on"
	echo " 1.filter_clusters.py 2.MpiClusterBsStat.py"
	echo 
	echo "1st digit: 1.(qsub) 2.(direct run)"
	echo "2nd digit: 1.(qsub) 2.(direct run)"
	exit
fi

schema=$1
input_file=$2
acc_cutoff=$3
runcode=$4

type_1=`echo $runcode|awk '{print substr($0,1,1)}'`     #{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`


acc_int=`echo $acc_cutoff|awk '{print $0*100}'`
mcl_table=mcl_$input_file
p_gene_table=p_gene_$input_file\_e5
gene_p_table=gene_p_$input_file\_e5_a$acc_int
good_cluster_table=good_cl_$input_file\_e5_a$acc_int
cluster_bs_table=cluster_bs_$input_file\_e5_a$acc_int

env	#10-02-05 try to see why threaded-program doesn't work in qsub system

check_exit_status() {
	return_code=$?
	if [ $return_code != "0" ]; then
		echo "Return code non-zero:"$return_code
		exit
	fi
}



date
case "$type_1" in
	1)	echo ssh $HOSTNAME ~/script/annot/bin/filter_clusters.py -k $schema -g $gene_p_table  -p $p_gene_table -m $mcl_table -l $good_cluster_table -c -n
		ssh $HOSTNAME ~/script/annot/bin/filter_clusters.py -k $schema -g $gene_p_table  -p $p_gene_table -m $mcl_table -l $good_cluster_table -c -n;;
	2)	echo ~/script/annot/bin/filter_clusters.py -k $schema -g $gene_p_table  -p $p_gene_table -m $mcl_table -l $good_cluster_table -c -n
		~/script/annot/bin/filter_clusters.py -k $schema -g $gene_p_table  -p $p_gene_table -m $mcl_table -l $good_cluster_table -c -n;;
	*)	echo "filter_clusters.py skipped";;
esac

check_exit_status

date

case "$type_2" in
	1)	echo ssh app2 qsub -@ ~/.qsub.options ~/script/shell/mpibs_stat.sh $schema $input_file $acc_cutoff
		ssh app2 qsub -@ ~/.qsub.options ~/script/shell/mpibs_stat.sh $schema $input_file $acc_cutoff;;
	2)	echo mpirun -np 5 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $good_cluster_table -l  $cluster_bs_table -c -n
		mpirun -np 5 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiClusterBsStat.py -k $schema -g $good_cluster_table -l  $cluster_bs_table -c -n;;
	*)	echo "MpiClusterBsStat.py skipped";;
esac

date
