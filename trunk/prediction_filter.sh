#!/bin/sh

if test $# -lt 5
then
	echo "Usage:"
	echo "    prediction_filter.sh SCHEMA INPUT_FILE LM_BIT ACC_CUTOFF RUNCODE NEWSFX PARAMETERS"
	echo
	echo "  NEWSFX is to be attached to the INPUT_FILE."
	echo "	  if NEWSFX=='n', it'll be ignored"
	echo "	  if NEWSFX=='zxxx', xxx will be attached to INPUT_FILE and"
	echo "	    PARAMETERS won't"
	echo "  PARAMETERS are passed to MpiPredictionFilter.py"
	echo "    like -u, -p, -m, -a and be processed to add to INPUT_FILE"
	echo
	echo "RUNCODE controls which part to turn on"
	echo " 1.MpiPredictionFilter.py 2.cluster_stat2.sh"
	echo
	echo " 1st digit: 1(qsub) 2(direct run)"
	echo " 2nd digit: 1(qsub) 2(direct run)"
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

echo "###### MpiPredictionFilter.py #####"
case "$type_1" in
	1)	echo mpirun -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiPredictionFilter.py -k $schema -i $input_file -j $new_input_file  -c $parameter
		mpirun -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiPredictionFilter.py -k $schema -i $input_file -j $new_input_file  -c $parameter;;
	2)	echo mpirun -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiPredictionFilter.py -k $schema -i $input_file -j $new_input_file  -c $parameter
		mpirun -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiPredictionFilter.py -k $schema -i $input_file -j $new_input_file  -c $parameter;;		
	*)	echo "MpiPredictionFilter.py skipped";;
esac

check_exit_status


echo "######## cluster_stat2.sh######"
case "$type_2" in
	1)	echo ssh app2 qsub -@ ~/.qsub.options -l mem=4G ~/script/shell/cluster_stat2.sh $schema $new_input_file $lm_bit $acc_cutoff 1111
		ssh app2 qsub -@ ~/.qsub.options -l mem=4G ~/script/shell/cluster_stat2.sh $schema $new_input_file $lm_bit $acc_cutoff 1111;;
	2)	echo ~/script/shell/cluster_stat2.sh $schema $new_input_file $lm_bit $acc_cutoff 1112
		~/script/shell/cluster_stat2.sh $schema $new_input_file $lm_bit $acc_cutoff 1112;;
	*)	echo "cluster_stat2.sh skipped";;
esac

check_exit_status
