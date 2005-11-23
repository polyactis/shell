#!/bin/sh

if test $# -lt 6
then
	echo "Usage: mpi_rpart_valid.sh SCHEMA INFNAME OUTPUTPREFIX cp_ls loss_ls prior_ls no_of_validations"
	echo
	echo "wrapper of MpiRpartValidation.py"
	exit
fi

schema=$1
infname=$2
output_prefix=$3
cp_ls=$4
loss_ls=$5
prior_ls=$6
no_of_validations=$7

output_file=~/MpiRpartValidation_out/$output_prefix\p$cp_ls\l$loss_ls\o$prior_ls\x$no_of_validations

n_hosts=$NSLOTS
old_machinefile=$TMPDIR/machines
machinefile=~/machines.$JOB_ID
cp $old_machinefile $machinefile

date
echo ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file -r -b -p $cp_ls -l $loss_ls -o $prior_ls -x $no_of_validations -s 0.9
ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file -r -b -p $cp_ls -l $loss_ls -o $prior_ls -x $no_of_validations -s 0.9

date

