#!/bin/sh

if test $# -lt 6
then
	echo "Usage:"
	echo "    fim_wrapper.sh SCHEMA MIN_SUPPORT MAX_SUPPORT LM_BIT ACC_CUTOFF RUNCODE OUTPUTSFX"
	echo 
	echo "This is batch script for fim_closed"
	echo
	echo "RUNCODE controls which part to turn on."
	echo "	The three digits correspond to "
	echo "	1.PreFimInput.py 2.fim_closed "
	echo "	3.MpiFromDatasetSignatureToPattern.py 4.cluster_stat.sh"
	echo "  (dense) 5.MpiCrackSplat.py 6.cluster_stat.sh"
	echo
	echo "1 means enable, 0 means disable"
	echo
	echo "3rd digit modes. 1 means using qsub assigned"
	echo "2 means to use 10 nodes in ~/hostfile"
	echo "3 means qsub + no_cc"
	echo "4 means 10 nodes + no_cc"
	echo
	echo "cluster_stat.sh: 1 use qsub(nodes by $NSLOTS), 2 just run"
	echo "5th digit: 1.(qsub) 2.(direct run)"
	echo
	echo "OUTPUTSFX is attached to the default outputfilename"
	exit
fi

schema=$1
support=$2
max_support=$3
lm_bit=$4
acc_cutoff=$5
runcode=$6
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`
type_5=`echo $runcode|awk '{print substr($0,5,1)}'`
type_6=`echo $runcode|awk '{print substr($0,6,1)}'`

outputsfx=''
while test -n "$7"
do
outputsfx=$outputsfx$7
shift
done

fim_input=/scratch/00/yuhuang/tmp/$schema\m$support\x$max_support\_i
fim_output=/scratch/00/yuhuang/tmp/$schema\m$support\x$max_support\_o
op=$schema\m$support\x$max_support$outputsfx
final_output=~/bin/hhu_clustering/data/output/netmine/$op

check_exit_status() {
	return_code=$?
	if [ $return_code != "0" ]; then
		echo "Return code non-zero:"$return_code
		exit
	fi
}

#the python library path
source ~/.bash_profile
date

if [ $type_1 = "1" ]; then
	echo ~/script/annot/bin/PreFimInput.py  -k $schema -m $support -x $max_support $fim_input
	~/script/annot/bin/PreFimInput.py  -k $schema -m $support -x $max_support $fim_input

fi

check_exit_status

date

if [ $type_2 = "1" ]; then
	echo ssh node29 ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $support
	ssh node29 ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $support
fi

check_exit_status

date

echo "########III. MpiFromDatasetSignatureToPattern.py######"
case "$type_3" in
	1)	echo mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output
		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output;;
	2)	echo mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output
		mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output;;
	3)	echo mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n
		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n;;
	4)	echo mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n
		mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n;;
	*)	echo "netmine_wrapper.py skipped";;
esac

check_exit_status

date


echo "########IV. cluster_stat on connected components######"
case "$type_4" in
	1)	echo ssh app2 qsub -@ ~/.qsub.options -pe mpich $NSLOTS ~/script/shell/cluster_stat.sh $schema $op $lm_bit $acc_cutoff 14403 zdf
		ssh app2 qsub -@ ~/.qsub.options -pe mpich $NSLOTS ~/script/shell/cluster_stat.sh $schema $op $lm_bit $acc_cutoff 14403 zdf;;
	2)	echo ~/script/shell/cluster_stat.sh $schema $op $lm_bit $acc_cutoff  24504 zdf
		~/script/shell/cluster_stat.sh $schema $op $lm_bit $acc_cutoff 24504 zdf;;
	*)	echo "cluster_stat.sh skipped";;
esac

check_exit_status

date


dfinal_output=$final_output\d50
echo "########V. dense clustering ######"
case "$type_5" in
	1)	echo mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output
		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output;;
	2)	echo mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output
		mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output;;
	*)	echo "MpiCrackSplat.py skipped";;
esac

check_exit_status

date

dop=$op\d50
echo "########VI. cluster_stat on dense clusters######"
case "$type_6" in
	1)	echo ssh app2 qsub -@ ~/.qsub.options -pe mpich $NSLOTS ~/script/shell/cluster_stat.sh $schema $dop $lm_bit $acc_cutoff 14403 zdf
		ssh app2 qsub -@ ~/.qsub.options -pe mpich $NSLOTS ~/script/shell/cluster_stat.sh $schema $dop $lm_bit $acc_cutoff 14403 zdf;;
	2)	echo ~/script/shell/cluster_stat.sh $schema $dop $lm_bit $acc_cutoff 24504 zdf
		~/script/shell/cluster_stat.sh $schema $dop $lm_bit $acc_cutoff 24504 zdf;;
	*)	echo "cluster_stat.sh skipped";;
esac

date
