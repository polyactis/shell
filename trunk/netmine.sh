#!/bin/sh

if test $# -lt 4
then
	echo "Usage:"
	echo "    netmine.sh OUTPUT_SUFFIX SCHEMA ORGANISM PARAMETERS"
	echo 
	echo "This is shell script simplifying running netmine"
	echo "PARAMETERS are -e -q -z (-w or -j --match_cut=)"
	echo "Ignore ORGANISM(05-16-05)"
	exit
fi

op=$1
schema=$2
organism=$3
parameter=''
while test -n "$4"
do
parameter=$parameter' '$4
shift
done

e_graph_fname=F$op\E

case "$schema" in
	sc_54_6661)	default_parameter="--mp=sc54_5 -n 6661 -p 1342902 -l54 -g1 -s200"
		echo "Default parameter is " $default_parameter;;
	mm_79)	default_parameter="--mp=mm79_5 -n24305  -p 4088951 -l79 -g1 -s200"
		echo "Default parameter is" $default_parameter;;
	sc_new_38)	default_parameter="--mp=sc_new_38_4 -n6661 -p1515677 -l38 -g1 -s200"
		echo "Default parameter is" $default_parameter;;
	mm_73)	default_parameter="--mp=mm_73_6 -n8513  -p5269747 -l73 -g1 -s200"
		echo "Default parameter is" $default_parameter;;
	*)	echo "Schema" $schema "not supported"
		exit 2;;

esac

#the python library path
source ~/.bash_profile
date

echo "########I. running netmine##########"
echo mpirun.lam N ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op
mpirun.lam N ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op

date

echo "########II. cluster_stat_sc on connected components######"
echo ~/script/shell/cluster_stat.sh $schema F$op $organism 1
~/script/shell/cluster_stat.sh $schema F$op $organism 1
date

echo "########III. 2nd-order clusters covering connected components###"
echo ~/script/annot/bin/EdgeClusterFromCopathOutput.py F$op $e_graph_fname
cd ~/bin/hhu_clustering/data/output/netmine/
~/script/annot/bin/EdgeClusterFromCopathOutput.py F$op $e_graph_fname

echo "########IV. cluster_stat_sc on 2nd-order clusters###"
echo ~/script/shell/cluster_stat.sh $schema $e_graph_fname $organism 1
~/script/shell/cluster_stat.sh $schema $e_graph_fname $organism 1
date

