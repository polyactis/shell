#!/bin/sh

if test $# -lt 5
then
	echo "Usage:"
	echo "    cluster_stat.sh SCHEMA INPUT_FILE LM_BIT ACC_CUTOFF RUNCODE NEWSFX PARAMETERS"
	echo
	echo "This is a script linking all stat programs"
	echo "  NEWSFX is to be attached to the INPUT_FILE."
	echo "	  if NEWSFX=='n', it'll be ignored"
	echo "	  if NEWSFX=='zxxx', xxx will be attached to INPUT_FILE and"
	echo "	    PARAMETERS won't"
	echo "  PARAMETERS are passed to MpiStatCluster.py and rpart_prediction.py"
	echo "  MpiStatCluster.py and rpart_prediction.py can't be run simultaneously."
	echo
	echo "RUNCODE controls which part to turn on"
	echo " 1.codense2db 2.cluster_stat.py"
	echo " 3.gene_stat 4.rpart_prediction.py 5.cluster_stat2.sh"
	echo
	echo " 1(codense2db.py, ALGORITHM type):"
	echo "   1(copath), 2(codense), 3(fim), 4(fimbfs)"
	echo "   5(biclustering), 0(skip)"
	echo " 2: 1(cluster_stat.py), 2(MpiClusterGeneStat.py)"
	echo "   3(MpiClusterGeneStat.py, qsub), 4(MpiStatCluster.py, qsub)"
	echo "	 5(MpiStatCluster.py, 10 nodes ~/hostfile)"
	echo "   6(MpiStatCluster.py, parallel, hpc-cmb)"
	echo "   if not ==1 , gene_stat.py will be off"
	echo " 5(cluster_stat2.sh): 1(lm, qsub) 2(lm, direct run)"
	echo "   3(OneParam...,qsub) 4(OneParam... no filter.sh, direct run)"
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
type_6=`echo $runcode|awk '{print substr($0,6,1)}'`

derive_tables() {
	splat_result_table=splat_$input_file
	mcl_result_table=mcl_$input_file
	pattern_table=pattern_$input_file #10-14-05
	cluster_stat_table=/scratch/00/yuhuang/cluster_stat/cluster_$input_file
	p_gene_table=p_gene_$input_file\_e5
}

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

setup_pe() {
	old_machinefile=$TMPDIR/machines
	new_machinefile=~/machines.$JOB_ID
	cp $old_machinefile $new_machinefile
	#10-23-05 NHOSTS from machinefile
	n_hosts=`wc $new_machinefile|awk '{print $1}'`
}

#the python library path
source ~/.bash_profile
check_exit_status
derive_tables
setup_pe
cd ~/bin/hhu_clustering/data/output/netmine/


case "$type_1" in
	1)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y1 -o $pattern_table -t $splat_result_table -m $mcl_result_table $input_file
		#copath results
		~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y1 -o $pattern_table -t $splat_result_table -m $mcl_result_table $input_file;;
	2)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y2 -o $pattern_table -t $splat_result_table -m $mcl_result_table $input_file
		#codense results
		~/script/annot/bin/codense/codense2db.py -k $schema -p ~/bin/hhu_clustering/$gene_id2no -c -y2 -o $pattern_table -t $splat_result_table -m $mcl_result_table $input_file;;
	3)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table -y3 $input_file
		#fim results
		~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table -y3 $input_file;;
	4)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table -y4 -g ~/mapping/$schema.gim $input_file
		#fimbfs results
		~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table -y4 -g ~/mapping/$schema.gim $input_file;;
	5)	echo ~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table $input_file
		#biclustering results
		~/script/annot/bin/codense/codense2db.py -k $schema -c -t $splat_result_table -m $mcl_result_table -o $pattern_table $input_file;;
	*)	echo "codense2db skipped";;
esac

check_exit_status


newsfx_1=`echo $newsfx|awk '{print substr($0,1,1)}'`	#{} is a must.
if [ $newsfx = 'n' ]; then	#'n' is for nothing
	newsfx=''
fi
if [ $newsfx_1 = 'z' ]; then
	newsfx_left=`echo $newsfx|awk '{print substr($0,2,100)}'` #100 is big
	new_input_file=$input_file$newsfx_left
else
	new_input_file=$input_file$newsfx`~/script/annot/bin/arguments2string.py $parameter`	#attach the additional arguments to the input_file name
fi
#05-19-05 cluster_stat goes to a file

case "$type_2" in
	1)	echo ssh $HOSTNAME ~/script/annot/bin/cluster_stat.py -k $schema -s $mcl_result_table  -p $cluster_stat_table -w -u 0
		#no parallel, cluster_stat.py
		ssh $HOSTNAME ~/script/annot/bin/cluster_stat.py -k $schema -s $mcl_result_table  -p $cluster_stat_table -w -u 0;;
	2)	echo mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c
		#parallel, 30 nodes from ~/hostfile
		mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c;;
	3)	echo mpirun.mpich -np $n_hosts -machinefile $new_machinefile /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c
		#parallel, nodes assigned by qsub, app2
		mpirun.mpich -np $n_hosts -machinefile $new_machinefile /usr/bin/mpipython ~/script/annot/bin/MpiClusterGeneStat.py -k $schema -s $mcl_result_table -p $cluster_stat_table -g $p_gene_table -c;;
	4)	echo ssh $HOSTNAME mpirun.mpich -np $n_hosts -machinefile $new_machinefile /usr/bin/mpipython ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		#parallel, nodes assigned by qsub, app2
		ssh $HOSTNAME mpirun.mpich -np $n_hosts -machinefile $new_machinefile /usr/bin/mpipython ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		input_file=$new_input_file	#10-23-05 change input_filie
		derive_tables;;
	5)	echo mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		#parallel, 10 nodes from ~/hostfile
		mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		input_file=$new_input_file	#10-23-05 change input_filie
		derive_tables;;
	6)	echo mpiexec ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		#parallel, hpc-cmb
		mpiexec ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		input_file=$new_input_file	#10-23-05 change input_filie
		derive_tables;;
	*)	echo "cluster_stat.py or MpiClusterGeneStat.py skipped";;
esac

check_exit_status


if [ $type_2 = "1" ]; then
	if [ $type_3 = "1" ]; then
		#05-19-05 cluster_stat goes to a file
		echo ~/script/annot/bin/gene_stat.py -k $schema -f $cluster_stat_table -m $mcl_result_table -g $p_gene_table -e 5 -l -w -c
		~/script/annot/bin/gene_stat.py -k $schema -f $cluster_stat_table -m $mcl_result_table -g $p_gene_table -e 5 -l -w -c
	fi
else
	echo "MpiClusterGeneStat.py is turned on, so gene_stat.py off"
fi

check_exit_status

app2=172.16.0.5
rpart_parameter=$parameter
new_input_file=$input_file`~/script/annot/bin/arguments2string.py $rpart_parameter`
echo "######## rpart_prediction.py ######"
case "$type_4" in
	1)	echo ssh $HOSTNAME ~/script/annot/bin/rpart_prediction.py -k $schema -i $input_file -j $new_input_file -c $rpart_parameter
		ssh $HOSTNAME ~/script/annot/bin/rpart_prediction.py -k $schema -i $input_file -j $new_input_file -c $rpart_parameter
		input_file=$new_input_file	#change input_filie
		derive_tables;;
	*)	echo "rpart_prediction.py skipped";;
esac

check_exit_status
echo "######## cluster_stat2.sh######"
case "$type_5" in
	1)	echo ssh $app2 qsub -@ ~/.qsub.options -l mem=4G ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 1111
		ssh $app2 qsub -@ ~/.qsub.options -l mem=4G ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 1111;;
	2)	echo ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 1112
		~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 1112;;
	3)	echo ssh $app2 qsub -@ ~/.qsub.options -l mem=4G ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 2111
		ssh $app2 qsub -@ ~/.qsub.options -l mem=4G ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 2111;;
	4)	echo ~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 2110
		~/script/shell/cluster_stat2.sh $schema $input_file $lm_bit $acc_cutoff 2110;;
	*)	echo "cluster_stat2.sh skipped";;
esac

check_exit_status


#echo "###### prediction_filter.sh #####"
#app2=172.16.0.5
#case "$type_5" in
#	1)	echo ssh $app2 qsub -@ ~/.qsub.options -pe mpich 10 ~/script/shell/prediction_filter.sh $schema $input_file $lm_bit $acc_cutoff 11 $newsfx $parameter
#		ssh $app2 qsub -@ ~/.qsub.options -pe mpich 10 ~/script/shell/prediction_filter.sh $schema $input_file $lm_bit $acc_cutoff 11 $newsfx $parameter;;
#	2)	echo ~/script/shell/prediction_filter.sh $schema $input_file $lm_bit $acc_cutoff 22 $newsfx $parameter
#		~/script/shell/prediction_filter.sh $schema $input_file $lm_bit $acc_cutoff 22 $newsfx $parameter;;
#	*)	echo "prediction_filter.sh skipped";;
#esac
#
#check_exit_status
#
