#!/bin/sh

if test $# -lt 4
then
	echo "Usage: mpi_rpart_valid.sh SCHEMA INFNAME OUTPUTPREFIX RUNCODE PARAMETERS"
	echo
	echo " runcode"
	echo " 1: parallel hpc-cmb, 2: qsub, 3: 6 nodes from ~/hostfile"
	echo " wrapper of MpiRpartValidation.py"
	exit
fi

schema=$1
infname=$2
output_prefix=$3
runcode=$4
parameter=''
while test -n "$5"
do
parameter=$parameter' '$5
shift
done

output_file=~/MpiRpartValidation_out/$output_prefix`~/script/annot/bin/arguments2string.py $parameter`
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`     #{} is a must.

date
case "$type_1" in
	1)	echo mpiexec ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  $parameter
		#parallel for hpc-cmb
	mpiexec ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  $parameter;;
	2)	n_hosts=$NSLOTS
	old_machinefile=$TMPDIR/machines
	machinefile=~/machines.$JOB_ID
	cp $old_machinefile $machinefile
	echo ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  $parameter
	#parallel on app2, nodes assigned by qsub
	ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file $parameter;;
	3)	n_hosts=6
		machinefile=~/hostfile
		echo ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  $parameter
		#parallel, 6 nodes from ~/hostfile
		ssh $HOSTNAME mpirun -np $n_hosts -machinefile $machinefile /usr/bin/mpipython ~/script/annot/bin/MpiRpartValidation.py -k $schema -i $infname -j $output_file  $parameter;;
	*)	echo "MpiRpartValidation.py skipped";;	
esac

date

