#!/bin/sh

if test $# -lt 5
then
	echo "Usage:"
	echo "    fim_wrapper.sh SCHEMA MIN_SUPPORT MAX_SUPPORT RUNCODE ACC_CUTOFF OUTPUTSFX"
	echo 
	echo "This is batch script for fim_closed"
	echo
	echo "RUNCODE controls which part to turn on."
	echo "	The three digits correspond to "
	echo "	1.PreFimInput.py 2.fim_closed "
	echo "	3.MpiFromDatasetSignatureToPattern.py 4.cluster_stat.sh"
	echo "1 means enable, 0 means disable"
	echo
	echo "Mpi... has two modes. 1 means using qsub assigned"
	echo "2 means to use 30 nodes in ~/hostfile"
	echo "3 means qsub + no_cc"
	echo "4 means 30 nodes + no_cc"
	echo
	echo "cluster_stat.sh: 1 use qsub, 2 just run"
	echo
	echo "OUTPUTSFX is attached to the default outputfilename"
	exit
fi

schema=$1
support=$2
max_support=$3
runcode=$4
acc_cutoff=$5
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`

outputsfx=''
while test -n "$6"
do
outputsfx=$outputsfx$6
shift
done

fim_input=/scratch/00/yuhuang/tmp/$schema\m$support\x$max_support\_i
fim_output=/scratch/00/yuhuang/tmp/$schema\m$support\x$max_support\_o
op=$schema\m$support\x$max_support$outputsfx
final_output=~/bin/hhu_clustering/data/output/netmine/$op

#the python library path
source ~/.bash_profile
date

if [ $type_1 = "1" ]; then
	echo ~/script/annot/bin/PreFimInput.py  -k $schema -m $support -x $max_support $fim_input
	~/script/annot/bin/PreFimInput.py  -k $schema -m $support -x $max_support $fim_input

fi

date

if [ $type_2 = "1" ]; then
	echo ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $support
	~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $support
fi

date

echo "########III. MpiFromDatasetSignatureToPattern.py######"
case "$type_3" in
	1)	echo mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output
		mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output;;
	2)	echo mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output
		mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output;;
	3)	echo mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n
		mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n;;
	4)	echo mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n
		mpirun.mpich -np 30 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n;;
	*)	echo "netmine_wrapper.py skipped";;
esac

date

echo "########IV. cluster_stat_sc on connected components######"
case "$type_4" in
	1)	echo ssh app2 qsub -@ ~/.qsub.options ~/script/shell/cluster_stat.sh $schema $op 320110  $acc_cutoff
		ssh app2 qsub -@ ~/.qsub.options ~/script/shell/cluster_stat.sh $schema $op 320110 $acc_cutoff;;
	2)	echo ~/script/shell/cluster_stat.sh $schema $op 320110 $acc_cutoff
		~/script/shell/cluster_stat.sh $schema $op 320110 $acc_cutoff;;
	*)	echo "cluster_stat.sh skipped";;
esac

date

