#!/bin/sh
#$ -pe mpich 18

if test $# -lt 5
then
	echo "Usage:"
	echo "    netmine.sh OUTPUT_SUFFIX SCHEMA SUPPORT RUNCODE ACC_CUTOFF PARAMETERS"
	echo 
	echo "This is shell script simplifying running netmine"
	echo "PARAMETERS are -e -q -z (-w or -j --match_cut=)"
	echo
	echo "RUNCODE controls which part to turn on."
	echo "	The three digits correspond to "
	echo "	1.netmine_wrapper.py, 2.cluster_stat.sh (CC),"
	echo "	3.cluster_stat.sh (2nd-order)"
	echo "1 means enable, 0 means disable"
	echo
	echo "netmine_wrapper has two modes. 1 means using qsub assigned"
	echo "2 means to use 20 nodes in ~/hostfile"
	echo
	echo "cluster_stat.sh: 1 use qsub, 2 just run"
	echo
	exit
fi

op=$1
schema=$2
#Ignore ORGANISM(05-16-05)
organism=$2
#05-20-05 add parameter support
support=$3
runcode=$4
acc_cutoff=$5
#05-23-05 use runcode to control which step is necessary
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`

parameter=''
while test -n "$6"
do
parameter=$parameter' '$6
shift
done

#05-20-05 getting no_of_genes, no_of_edges, no_of_columns
matrix_prefix=$schema\_$support
matrix_file=~/bin/hhu_clustering/data/input/$matrix_prefix
echo "Getting no_of_genes..."
#05-24-05 get no_of_genes from the mapping file
no_of_genes=`wc ~/bin/hhu_clustering/$schema\_gene_id2no|awk '{print $1}'`
echo "Getting no_of_edges..."
no_of_edges=`wc $matrix_file.cor_vector|awk '{print $1}'`
echo "Getting no_of_columns..."
no_of_columns=`~/script/shell/count_columns.py $matrix_file.cor_vector|awk '{print $3}'`
#the first and second column is the edge id
no_of_columns=`expr $no_of_columns - 2`
default_parameter="--mp=$matrix_prefix -n $no_of_genes -p $no_of_edges -l $no_of_columns -g1 -s200"
echo "Default parameter is" $default_parameter

e_graph_fname=F$op\E

#the python library path
source ~/.bash_profile
date

case "$type_1" in
	1)	echo mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op
		mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op;;
	2)	echo mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op
		mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op;;
	*)	echo "netmine_wrapper.py skipped";;
esac

date

echo "########II. cluster_stat_sc on connected components######"
case "$type_2" in
	1)	echo ssh app2 qsub -@ ~/.qsub.options ~/script/shell/cluster_stat.sh $schema F$op 111110  $acc_cutoff
		ssh app2 qsub -@ ~/.qsub.options ~/script/shell/cluster_stat.sh $schema F$op 111110 $acc_cutoff;;
	2)	echo ~/script/shell/cluster_stat.sh $schema F$op 111110 $acc_cutoff
		~/script/shell/cluster_stat.sh $schema F$op 111110 $acc_cutoff;;
	*)	echo "cluster_stat.sh skipped";;
esac

date

if [ $type_3 = "1" ]; then
	echo "########III. 2nd-order clusters covering connected components###"
	echo ~/script/annot/bin/EdgeClusterFromCopathOutput.py F$op $e_graph_fname
	cd ~/bin/hhu_clustering/data/output/netmine/
	~/script/annot/bin/EdgeClusterFromCopathOutput.py F$op $e_graph_fname

	echo "########IV. cluster_stat_sc on 2nd-order clusters###"
	echo ssh app2 qsub -@ ~/.qsub.options ~/script/shell/cluster_stat.sh $schema $e_graph_fname 111110 $acc_cutoff
	ssh app2 qsub -@ ~/.qsub.options ~/script/shell/cluster_stat.sh $schema $e_graph_fname 111110 $acc_cutoff
	date
fi
