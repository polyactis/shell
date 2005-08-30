#!/bin/sh

if test $# -lt 3
then
	echo "Usage:"
	echo "    cluster_stat.sh SCHEMA INPUT_FILE RUNCODE ACC_CUTOFF PARAMETERS"
	echo
	echo "This is a script linking all stat programs"
	echo "PARAMETERS are passed to cluster_stat.py"
	echo "Except -k -s -p -b -w -u, others are ok, like -n and -e."
	echo
	echo "RUNCODE controls which part to turn on"
	echo " 1.codense2db 2.cluster_stat.py"
	echo " 3.gene_stat 4.p_gene_analysis"
	echo " 5.gene_p_map_redundancy 6.connectivity_original"
	echo 
	echo " First digit is ALGORITHM type."
	echo "   1(copath), 2(codense), 3(fim), 4(biclustering), 0(skip)"
	echo " Second digit: 1(cluster_stat.py), 2(MpiClusterGeneStat.py)"
	echo "   3(MpiClusterGeneStat.py, nodes assigned by qsub)"
	echo "   if MpiClusterGeneStat.py is on, gene_stat.py will be off"
	echo " Fourth digit: two choices, 1(p_gene_lm + p_gene_analysis)"
	echo "   2(p_gene_analysis)"
	exit
fi

schema=$1
input_file=$2
runcode=$3
acc_cutoff=$4

type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`
type_5=`echo $runcode|awk '{print substr($0,5,1)}'`
type_6=`echo $runcode|awk '{print substr($0,6,1)}'`
splat_result_table=splat_$2
mcl_result_table=mcl_$2
#05-19-05 cluster_stat goes to a file
cluster_stat_table=/scratch/00/yuhuang/cluster_stat/cluster_$2
p_gene_table=p_gene_$2_e5
acc_int=`echo $acc_cutoff|awk '{print $0*100}'`
lm_table=lm_$2\_e5_a$acc_int
gene_p_table=gene_p_$2\_e5_a$acc_int
gene_id2no=$schema\_gene_id2no
echo $gene_id2no


parameter=''
while test -n "$5"
do
parameter=$parameter' '$5
shift
done

echo " RUNCODE is $runcode "
echo "parameter to cluster_stat.py is $parameter"


#the python library path
source ~/.bash_profile
date
cd ~/bin/hhu_clustering/data/output/netmine/

case "$type_1" in
	1)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y1 -t $splat_result_table -m $mcl_result_table $input_file
		~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y1 -t $splat_result_table -m $mcl_result_table $input_file;;
	2)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y2 -t $splat_result_table -m $mcl_result_table $input_file
		~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y2 -t $splat_result_table -m $mcl_result_table $input_file;;
	3)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -y3 $input_file
		~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -y3 $input_file;;
	4)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table $input_file
		~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table $input_file;;
	*)	echo "codense2db skipped";;
esac

#05-19-05 cluster_stat goes to a file


case "$type_2" in
	1)	echo ssh node24 ~/script/annot/bin/cluster_stat.py -k $schema -s $mcl_result_table  -p $cluster_stat_table -w -u 0 $parameter
		ssh node24 ~/script/annot/bin/cluster_stat.py -k $schema -s $mcl_result_table  -p $cluster_stat_table -w -u 0 $parameter;;
	2)	echo mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c
		mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c;;
	3)	echo mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c
		mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c;;
	*)	echo "cluster_stat.py or MpiClusterGeneStat.py skipped";;
esac

if [ $type_2 != "2" ]; then
	if [ $type_3 = "1" ]; then
		#05-19-05 cluster_stat goes to a file
		echo ~/script/annot/bin/gene_stat.py -k $schema -f $cluster_stat_table -m $mcl_result_table -g $p_gene_table -e 5 -l -w -c
		~/script/annot/bin/gene_stat.py -k $schema -f $cluster_stat_table -m $mcl_result_table -g $p_gene_table -e 5 -l -w -c
	fi
else
	echo "MpiClusterGeneStat.py is turned on, so gene_stat.py off"
fi


case "$type_4" in
	1)	echo ssh node27 ~/script/shell/p_gene_lm.sh $schema $input_file $acc_cutoff
		ssh node27 ~/script/shell/p_gene_lm.sh $schema $input_file $acc_cutoff
		#p_gene_lm calls rpy.r, which is banned by qsub. run it elsewhere
		echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0 -l $lm_table -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0 -l $lm_table -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	2)	echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	*)	echo "No p_gene_analysis and/or p_gene_lm";;
esac


if [ $type_5 = "1" ]; then
	echo ~/script/annot/bin/gene_p_map_redundancy.py -k $schema -t $p_gene_table -n $gene_p_table -c
	~/script/annot/bin/gene_p_map_redundancy.py -k $schema -t $p_gene_table -n $gene_p_table -c
fi


if [ $type_6 = "1" ]; then
	echo ~/script/annot/bin/connectivity_original.py -k $schema -c -t $mcl_result_table
	~/script/annot/bin/connectivity_original.py -k $schema -c -t $mcl_result_table
fi
date
