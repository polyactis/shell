#!/bin/sh
#$ -pe mpich 18

if test $# -lt 5
then
	echo "Usage:"
	echo "    netmine.sh OUTPUT_SUFFIX SCHEMA SUPPORT RUNCODE PARAMETERS"
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
	exit
fi

op=$1
schema=$2
#Ignore ORGANISM(05-16-05)
organism=$2
#05-20-05 add parameter support
support=$3
runcode=$4
#05-23-05 use runcode to control which step is necessary
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`

parameter=''
while test -n "$5"
do
parameter=$parameter' '$5
shift
done

#05-20-05 getting no_of_genes, no_of_edges, no_of_columns
matrix_prefix=$schema\_$support
matrix_file=~/bin/hhu_clustering/data/input/$matrix_prefix
echo "Getting no_of_genes..."
no_of_genes=`wc $matrix_file.matrix|awk '{print $1}'`
echo "Getting no_of_edges..."
no_of_edges=`wc $matrix_file.cor_vector|awk '{print $1}'`
echo "Getting no_of_columns..."
no_of_columns=`~/script/shell/count_columns.py $matrix_file.cor_vector|awk '{print $3}'`
#the first and second column is the edge id
no_of_columns=`expr $no_of_columns - 2`
default_parameter="--mp=$matrix_prefix -n $no_of_genes -p $no_of_edges -l $no_of_columns -g1 -s200"
echo "Default parameter is" $default_parameter

e_graph_fname=F$op\E

#05-20-05 no more schema guessing

#case "$schema" in
#	sc_54_6661)	default_parameter="--mp=sc54_5 -n 6661 -p 1342902 -l54 -g1 -s200"
#		echo "Default parameter is " $default_parameter;;
#	mm_79)	default_parameter="--mp=mm_79_5 -n24305  -p 4088951 -l79 -g1 -s200"
#		echo "Default parameter is" $default_parameter;;
#	sc_new_38)	default_parameter="--mp=sc_new_38_4 -n6661 -p1515677 -l38 -g1 -s200"
#		echo "Default parameter is" $default_parameter;;
#	mm_73)	default_parameter="--mp=mm_73_6 -n8513  -p5269747 -l73 -g1 -s200"
#		echo "Default parameter is" $default_parameter;;
#	*)	echo "Schema" $schema "not supported"
#		exit 2;;
#
#esac

#the python library path
source ~/.bash_profile
date

if [ $type_1 = "1" ]; then
	echo "########I. running netmine##########"
	#echo mpirun.lam C ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op
	#mpirun.lam C ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op
	#05-19-05 mpich start to use 40 nodes
	#05-21-05 mpich uses 20 big memory nodes
	echo mpirun.mpich -np 20 -machinefile ~/hostfile_2 /usr/bin/mpipython ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op
	mpirun.mpich -np 20 -machinefile ~/hostfile_2 /usr/bin/mpipython ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op
fi

date

if [ $type_2 = "1" ]; then
	echo "########II. cluster_stat_sc on connected components######"
	echo ~/script/shell/cluster_stat.sh $schema F$op $organism 1
	~/script/shell/cluster_stat.sh $schema F$op $organism 1
	date
fi

if [ $type_3 = "1" ]; then
	echo "########III. 2nd-order clusters covering connected components###"
	echo ~/script/annot/bin/EdgeClusterFromCopathOutput.py F$op $e_graph_fname
	cd ~/bin/hhu_clustering/data/output/netmine/
	~/script/annot/bin/EdgeClusterFromCopathOutput.py F$op $e_graph_fname

	echo "########IV. cluster_stat_sc on 2nd-order clusters###"
	echo ~/script/shell/cluster_stat.sh $schema $e_graph_fname $organism 1
	~/script/shell/cluster_stat.sh $schema $e_graph_fname $organism 1
	date
fi
