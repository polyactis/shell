#!/bin/sh

if test $# -lt 5
then
	echo "Usage:"
	echo "    cluster_stat.sh SCHEMA INPUT_FILE LM_BIT ACC_CUTOFF RUNCODE NEWSFX PARAMETERS"
	echo
	echo "This is a script linking all stat programs"
	echo "  NEWSFX and PARAMETERS are passed to prediction_filter.sh"
	echo "    like -u, -p, -m, -a"
	echo
	echo "RUNCODE controls which part to turn on"
	echo " 1.codense2db 2.cluster_stat.py"
	echo " 3.gene_stat 4.cluster_stat2.sh"
	echo " 5.prediction_filter.sh"
	echo
	echo " 1st digit is ALGORITHM type."
	echo "   1(copath), 2(codense), 3(fim), 4(biclustering), 0(skip)"
	echo " 2nd digit: 1(cluster_stat.py), 2(MpiClusterGeneStat.py)"
	echo "   3(MpiClusterGeneStat.py, nodes assigned by qsub)"
	echo "   if MpiClusterGeneStat.py is on, gene_stat.py will be off"
	echo " 4th digit: 1(qsub) 2(direct run)"
	echo " 5th digit: 1(qsub) 2(direct run)"
	exit
fi

schema=$1
input_file=$2
lm_bit=$3
acc_cutoff=$4
runcode=$5
newsfx=$6
parameter=''
while test -n "$7"
do
parameter=$parameter' '$7
shift
done

type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`
type_5=`echo $runcode|awk '{print substr($0,5,1)}'`

splat_result_table=splat_$input_file
mcl_result_table=mcl_$input_file
pattern_table=pattern_$input_file #10-14-05
cluster_stat_table=/scratch/00/yuhuang/cluster_stat/cluster_$input_file
p_gene_table=p_gene_$input_file\_e5

gene_id2no=$schema\_gene_id2no
echo $gene_id2no

echo " RUNCODE is $runcode "

check_exit_status() {
	date
	return_code=$?
	if [ $return_code != "0" ]; then
		echo "Return code non-zero:"$return_code
		exit
	fi
}

#the python library path
source ~/.bash_profile
date
cd ~/bin/hhu_clustering/data/output/netmine/

case "$type_1" in
	1)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y1 -o $pattern_table -t $splat_result_table -m $mcl_result_table $input_file
		~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y1 -o $pattern_table -t $splat_result_table -m $mcl_result_table $input_file;;
	2)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y2 -o $pattern_table -t $splat_result_table -m $mcl_result_table $input_file
		~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y2 -o $pattern_table -t $splat_result_table -m $mcl_result_table $input_file;;
	3)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table -y3 $input_file
		~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table -y3 $input_file;;
	4)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table $input_file
		~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table $input_file;;
	*)	echo "codense2db skipped";;
esac

check_exit_status

#05-19-05 cluster_stat goes to a file

case "$type_2" in
	1)	echo ssh $HOSTNAME ~/script/annot/bin/cluster_stat.py -k $schema -s $mcl_result_table  -p $cluster_stat_table -w -u 0
		ssh $HOSTNAME ~/script/annot/bin/cluster_stat.py -k $schema -s $mcl_result_table  -p $cluster_stat_table -w -u 0;;
	2)	echo mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c
		mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c;;
	3)	echo mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c
		mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c;;
	*)	echo "cluster_stat.py or MpiClusterGeneStat.py skipped";;
esac

check_exit_status


if [ $type_2 != "2" ]; then
	if [ $type_3 = "1" ]; then
		#05-19-05 cluster_stat goes to a file
		echo ~/script/annot/bin/gene_stat.py -k $schema -f $cluster_stat_table -m $mcl_result_table -g $p_gene_table -e 5 -l -w -c
		~/script/annot/bin/gene_stat.py -k $schema -f $cluster_stat_table -m $mcl_result_table -g $p_gene_table -e 5 -l -w -c
	fi
else
	echo "MpiClusterGeneStat.py is turned on, so gene_stat.py off"
fi

check_exit_status


echo "######## cluster_stat2.sh######"
case "$type_4" in
	1)	echo ssh app2 qsub -@ ~/.qsub.options -l mem=4G ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 1111
		ssh app2 qsub -@ ~/.qsub.options -l mem=4G ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 1111;;
	2)	echo ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 1112
		~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 1112;;
	*)	echo "cluster_stat2.sh skipped";;
esac

check_exit_status


echo "###### prediction_filter.sh #####"
app2=176.16.0.5	#10-16-05 it seems dns-hard to ssh app2 from node
case "$type_5" in
	1)	echo ssh $app2 qsub -@ ~/.qsub.options -pe mpich 10 ~/script/shell/prediction_filter.sh $schema $input_file $lm_bit $acc_cutoff 11 $newsfx $parameter
		ssh $app2 qsub -@ ~/.qsub.options -pe mpich 10 ~/script/shell/prediction_filter.sh $schema $input_file $lm_bit $acc_cutoff 11 $newsfx $parameter;;
	2)	echo ~/script/shell/prediction_filter.sh $schema $input_file $lm_bit $acc_cutoff 22 $newsfx $parameter
		~/script/shell/prediction_filter.sh $schema $input_file $lm_bit $acc_cutoff 22 $newsfx $parameter;;
	*)	echo "prediction_filter.sh skipped";;
esac

check_exit_status

