#!/bin/sh

if test $# -lt 6
then
	echo "Usage:"
	echo "    fim_wrapper.sh SCHEMA SG_MIN_SUPPORT MIN_SUPPORT MAX_SUPPORT LM_BIT ACC_CUTOFF RUNCODE OUTPUTSFX"
	echo 
	echo "SG_MIN_SUPPORT is the minimum support for that summary graph."
	echo
	echo "RUNCODE controls which part to turn on."
	echo "	The three digits correspond to "
	echo "	1.PreFimInput.py 2.fim_closed "
	echo "	3.MpiFromDatasetSignatureToPattern.py 4.cluster_stat.sh"
	echo "  (dense) 5.MpiCrackSplat.py 6.cluster_stat.sh"
	echo
	echo "Each digit in RUNCODE:"
	echo
	echo "1(PreFimInput.py):"
	echo "  1, for fim_closed"
	echo "  2, for closet+"
	echo "2(fim_closed):"
	echo "  1, app2, ssh node29"
	echo "  2, direct run"
	echo "  3, closet+"
	echo "3(MpiFromDatasetSignatureToPattern.py):"
	echo "  1, app2, qsub assigned"
	echo "  2, 10 nodes in ~/hostfile"
	echo "  3, qsub + no_cc"
	echo "  4, 10 nodes + no_cc"
	echo "  5, hpc-cmb, nodes assigned by qsub"
	echo
	echo "4 & 6(cluster_stat.sh): forget it."
	echo "  1 use qsub(nodes by $NSLOTS), 2 just run"
	echo 
	echo "5(MpiCrackSplat.py):"
	echo " 1.(qsub) 2.(direct run) 3.(hpc-cmb, qsub)"
	echo
	echo "OUTPUTSFX is attached to the default outputfilename"
	exit
fi

schema=$1
sg_min_support=$2
shift	#insert sg_min_support
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

edge_sig_vector_fname=~/bin/hhu_clustering/data/input/$schema\_$sg_min_support.sig_vector
fim_input=~/tmp/fim_wrapper/$schema\m$support\x$max_support\_i
closet_input_spec=~/tmp/fim_wrapper/$schema\m$support\x$max_support\_i.spec
closet_output=~/tmp/fim_wrapper/$schema\m$support\x$max_support\_closet_o
fim_output=~/tmp/fim_wrapper/$schema\m$support\x$max_support\_o
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

case "$type_1" in
	1)	echo ~/script/annot/bin/PreFimInput.py  -s $edge_sig_vector_fname -m $support -x $max_support $fim_input
		#for fim_closed
		~/script/annot/bin/PreFimInput.py  -s $edge_sig_vector_fname -m $support -x $max_support $fim_input;;
	2)	echo ~/script/annot/bin/PreFimInput.py  -s $edge_sig_vector_fname -m $support -x $max_support -y2 $fim_input
		#for closet+
		~/script/annot/bin/PreFimInput.py  -s $edge_sig_vector_fname -m $support -x $max_support -y2 $fim_input;;
	*)	echo "PreFimInput.py skipped";;
esac

check_exit_status

date

case "$type_2" in
	1)	echo ssh node29 ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $support
		#for app2, use big node
		ssh node29 ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $support;;
	2)	echo ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $support
		#just run, (hpc-cmb)
		~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $support;;
	3)	echo ~/script/hhu_clustering/bin/closet+ $closet_input_spec 4 $fim_output $support
		#closet+ just run, (hpc-cmb)
		~/script/hhu_clustering/bin/closet+ $closet_input_spec 4 $fim_output $support;;
		#echo ~/script/annot/bin/PostFim.py -i $closet_output -m $support -o $fim_output
		#needs PostFim.py, to convert the format to fim_closed for followup program
		#~/script/annot/bin/PostFim.py -i $closet_output -m $support -o $fim_output;;
	*)	echo "fim_closed/closet+ skipped";;
esac

check_exit_status

date

echo "########III. MpiFromDatasetSignatureToPattern.py######"
case "$type_3" in
	1)	echo mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output
		#app2, nodes assigned by qsub
		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output;;
	2)	echo mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output
		#10 nodes from ~/hostfile
		mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output;;
	3)	echo mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n
		#app2, nodes assigned by qsub, no_cc(no connected components)
		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n;;
	4)	echo mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n
		#10 nodes from ~/hostfile, no_cc(no connected components)
		mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -o $final_output -n;;
	5)	echo mpiexec ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -s $edge_sig_vector_fname -o $final_output
		#hpc-cmb, nodes assigned by qsub
		mpiexec ~/script/annot/bin/MpiFromDatasetSignatureToPattern.py -k $schema -m $support -x $max_support -i $fim_output -s $edge_sig_vector_fname -o $final_output;;
	*)	echo "MpiFromDatasetSignatureToPattern.py skipped";;
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
		#app2, nodes assigned by qsub
		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output;;
	2)	echo mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output
		#20 nodes from ~/hostfile
		mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output;;
	3)	echo mpiexec ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output
		#hpc-cmb, nodes assigned by qsub
		mpiexec ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output;;
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
