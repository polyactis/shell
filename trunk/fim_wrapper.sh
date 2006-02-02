#!/bin/sh

if test $# -lt 6
then
	echo "Usage:"
	echo "    fim_wrapper.sh SCHEMA SG_MIN_SUPPORT MIN_SUPPORT MAX_SUPPORT FIM_SUPPORT RUNCODE NEWSFX PARAMETERS"
	echo 
	echo "SG_MIN_SUPPORT is the minimum support for that summary graph."
	echo "MIN_SUPPORT MAX_SUPPORT is to pick edges from summary graph."
	echo "FIM_SUPPORT is the minimum support of the pattern"
	echo "	if RUNCODE[:3]='999', INPUT_FILE is FIM_SUPPORT; otherwise, it's fim_prefix"
	echo "NEWSFX is to be attached to the INPUT_FILE."
	echo "	if NEWSFX=='n', it'll be ignored"
	echo "	if NEWSFX=='zxxx', xxx will be attached to INPUT_FILE and PARAMETERS won't"
	echo "PARAMETERS are passed to MpiStatCluster.py"
	echo
	echo "RUNCODE controls which part to turn on."
	echo "	The three digits correspond to "
	echo "	1.PreFimInput.py 2.fim_closed "
	echo "	3.MpiFromDatasetSignatureToPattern.py 4.MpiBFSCluster.py"
	echo " 5.MpiStatCluster.py 6. SelectClusterPrediction.py(need ~/mapping/$schema\.gim)"
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
	echo "4(MpiBFSCluster.py):"
	echo "   1(qsub, app2), 2(10 nodes ~/hostfile), 3(parallel, hpc-cmb)"
	echo "5(MpiStatCluster.py):"
	echo "   1(qsub, app2), 2(10 nodes ~/hostfile), 3(parallel, hpc-cmb)"
	echo
	exit
fi

schema=$1
sg_min_support=$2
support=$3
max_support=$4
fim_support=$5
runcode=$6
newsfx=$7
parameter=''
while test -n "$8"
do
parameter=$parameter' '$8
shift
done

type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`
type_5=`echo $runcode|awk '{print substr($0,5,1)}'`
type_6=`echo $runcode|awk '{print substr($0,6,1)}'`

edge_sig_vector_fname=~/bin/hhu_clustering/data/input/$schema\_$sg_min_support.sig_vector
fim_prefix=$schema\m$support\x$max_support\f$fim_support
fim_input=~/tmp/fim_wrapper/$fim_prefix\_i
closet_input_spec=$fim_input.spec
closet_output=~/tmp/fim_wrapper/$fim_prefix\_closet_o
fim_output=~/tmp/fim_wrapper/$fim_prefix\_o
final_output=~/bin/hhu_clustering/data/output/netmine/$fim_prefix

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


case "$type_2" in
	1)	echo ssh node29 ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $fim_support
		#for app2, use big node
		ssh node29 ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $fim_support;;
	2)	echo ~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $fim_support
		#just run, (hpc-cmb)
		~/script/fimi06/bin/fim_closed $fim_input 4 $fim_output $fim_support;;
	3)	echo ~/script/hhu_clustering/bin/closet+ $closet_input_spec 4 $fim_output $fim_support
		#closet+ just run, (hpc-cmb)
		~/script/hhu_clustering/bin/closet+ $closet_input_spec 4 $fim_output $fim_support;;
		#echo ~/script/annot/bin/PostFim.py -i $closet_output -m $support -o $fim_output
		#needs PostFim.py, to convert the format to fim_closed for followup program
		#~/script/annot/bin/PostFim.py -i $closet_output -m $support -o $fim_output;;
	*)	echo "fim_closed/closet+ skipped";;
esac

check_exit_status


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
#'
prev_3_runcode=$type_1$type_2$type_3
if [ $prev_3_runcode = '999' ]; then
	input_file=$fim_support
else
	input_file=$fim_prefix	#02-01-06 input_file is just the fim_prefix
fi
cd ~/bin/hhu_clustering/data/output/netmine/	#02-01-06 WATCH this

case "$type_4" in
	1)	echo mpirun -np $n_hosts -machinefile $new_machinefile /usr/bin/mpipython ~/script/annot/bin/MpiBFSCluster.py -i $input_file -o $input_file\bfs -g $edge_sig_vector_fname -m $support -x $max_support
		#parallel, nodes assigned by qsub
		mpirun -np $n_hosts -machinefile $new_machinefile /usr/bin/mpipython ~/script/annot/bin/MpiBFSCluster.py -i $input_file -o $input_file\bfs -g $edge_sig_vector_fname -m $support -x $max_support
		input_file=$input_file\bfs;;
	2)	echo mpirun -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiBFSCluster.py -i $input_file -o $input_file\bfs -g $edge_sig_vector_fname -m $support -x $max_support
		#parallel, 10 nodes from ~/hostfile
		mpirun -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiBFSCluster.py -i $input_file -o $input_file\bfs -g $edge_sig_vector_fname -m $support -x $max_support
		input_file=$input_file\bfs;;
	3)	echo mpiexec ~/script/annot/bin/MpiBFSCluster.py -i $input_file -o $input_file\bfs -g $edge_sig_vector_fname -m $support -x $max_support
		#parallel, hpc-cmb
		mpiexec ~/script/annot/bin/MpiBFSCluster.py -i $input_file -o $input_file\bfs -g $edge_sig_vector_fname -m $support -x $max_support
		input_file=$input_file\bfs;;
	*)	echo "MpiBFSCluster.py skipped";;
esac

check_exit_status

#02-01-06 copied from cluster_stat.py

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

case "$type_5" in
	1)	echo ssh $HOSTNAME mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		#parallel, nodes assigned by qsub, app2
		ssh $HOSTNAME mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter;;
	2)	echo mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		#parallel, 10 nodes from ~/hostfile
		mpirun.mpich -np 10 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter;;
	3)	echo mpiexec ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter
		#parallel, hpc-cmb
		mpiexec ~/script/annot/bin/MpiStatCluster.py -k $schema -i $input_file -j $new_input_file $parameter;;
	*)	echo "cluster_stat.py or MpiClusterGeneStat.py skipped";;
esac

check_exit_status

case "$type_6" in
	1)	echo ~/script/annot/bin/SelectClusterPrediction.py -k $schema -i $input_file -s $new_input_file -j $new_input_file -m ~/mapping/$schema\.gim -c
		#SelectClusterPrediction.py
		~/script/annot/bin/SelectClusterPrediction.py -k $schema -i $input_file -s $new_input_file -j $new_input_file -m ~/mapping/$schema\.gim -c;;
	*)	echo "SelectClusterPrediction.py skipped";;
esac

check_exit_status

#dfinal_output=$final_output\d50
#echo "########V. dense clustering ######"
#case "$type_6" in
#	1)	echo mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output
#		#app2, nodes assigned by qsub
#		mpirun.mpich -np $NSLOTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output;;
#	2)	echo mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output
#		#20 nodes from ~/hostfile
#		mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output;;
#	3)	echo mpiexec ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output
#		#hpc-cmb, nodes assigned by qsub
#		mpiexec ~/script/annot/bin/MpiCrackSplat.py -k $schema -i $final_output -m $support -x $max_support -c 0.5 -o $dfinal_output;;
#	*)	echo "MpiCrackSplat.py skipped";;
#esac
#
#check_exit_status
#
#date
