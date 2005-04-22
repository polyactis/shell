#!/bin/sh

if test $# -lt 3
then
	echo "Usage:"
	echo "    netmine.sh OUTPUT_SUFFIX ORGANISM PARAMETERS"
	echo 
	echo "This is shell script simplifying running netmine"
	exit
fi

op=$1
organism=$2
parameter=''
while test -n "$3"
do
parameter=$parameter' '$3
shift
done
#parameter is -q -z (-w or -j --match_cut=)

e_graph_fname=F$op\E

if [ $organism = "sc" ]
then
	default_parameter="--mp=sc54_5 -n 6661 -p 1342902 -l54 -e6 -g1 -s200"
	schema=sc_54_6661
	echo "Default parameter is " $default_parameter
	elif [ $organism = "mm" ]
	then
		default_parameter="--mp=mm79_5 -n24305  -p 4088951 -l79 -e6 -g1 -s200"
		schema=mm_79
		echo "Default parameter is" $default_parameter
		else
			echo "Organism not supported."
			exit
fi

#the python library path
source ~/.bash_profile
date

echo "########I. running netmine##########"
echo mpirun N ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op
mpirun N ~/script/annot/bin/netmine_wrapper.py $default_parameter $parameter --op=$op

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

