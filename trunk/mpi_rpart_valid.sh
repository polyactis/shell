#!/bin/sh

if test $# -lt 6
then
	echo "Usage: mpi_rpart_valid.sh SCHEMA INFNAME OUTPUTPREFIX cp_ls loss_ls prior_ls no_of_validations runcode"
	echo
	echo " runcode"
	echo " 1: parallel hpc-cmb, 2: qsub, 3: 6 nodes from ~/hostfile"
	echo " wrapper of MpiRpartValidation.py"
	exit
fi

schema=$1
infname=$2
output_prefix=$3
cp_ls=$4
loss_ls=$5
prior_ls=$6
no_of_validations=$7
runcode=$8

output_file=~/MpiRpartValidation_out/$output_prefix\p$cp_ls\l$loss_ls\o$prior_ls\x$no_of_validations
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`     #{} is a must.

date
case "$type_1" in
	1)	echo mpiexec ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  -p $cp_ls -l $loss_ls -o $prior_ls -x $no_of_validations -s 0.9
		#parallel for hpc-cmb
	mpiexec ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  -p $cp_ls -l $loss_ls -o $prior_ls -x $no_of_validations -s 0.9;;
	2)	n_hosts=$NSLOTS
	old_machinefile=$TMPDIR/machines
	machinefile=~/machines.$JOB_ID
	cp $old_machinefile $machinefile
	echo ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  -p $cp_ls -l $loss_ls -o $prior_ls -x $no_of_validations -s 0.9
	#parallel on app2, nodes assigned by qsub
	ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  -p $cp_ls -l $loss_ls -o $prior_ls -x $no_of_validations -s 0.9;;
	3)	n_hosts=6
		machinefile=~/hostfile
		echo ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  -p $cp_ls -l $loss_ls -o $prior_ls -x $no_of_validations -s 0.9
		#parallel, 6 nodes from ~/hostfile
		ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  -p $cp_ls -l $loss_ls -o $prior_ls -x $no_of_validations -s 0.9;;
	*)	echo "MpiRpartValidation.py skipped";;	
esac

date

