#!/bin/sh
if test $# -ne 4
then
	echo "Usage:"
	echo "   annot.sh ORGANISM SCHEMA MIN_SUPPORT RUNCODE"
	echo ""
	echo "RUNCODE's digits control:"
	echo "  1 SchemaDatasetSetup.py, 2 SchemaPreSetup.sh"
	echo "  3 graph_merge.sh, 4 netmine.sh or fim_wrapper.sh"
	echo " For graph_merge.sh:"
	echo "	1 graph_merge_lam.py(non-qsub)+complete_cor_vector(non-qsub)"
	echo "	2 graph_merge.py+complete_cor_vector.py(qsub)"
	echo "	3 graph_merge_lam.py(qsub)+complete_cor_vector(qsub)"
	echo " For the 4th digit:"
	echo "	1 netmine.sh, 2 fim_wrapper.sh(qsub)"
	echo
	exit
fi

organism=$1
schema=$2
min_support=$3
runcode=$4
#08-16-05 use runcode to control which step is necessary
type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`

#the python library path
source ~/.bash_profile

case "$type_1" in
	1)	echo "########## ~/script/shell/SchemaDatasetSetup.py -k $schema  -g $organism -f ~/datasets/mapping/$schema ##########"
		~/script/shell/SchemaDatasetSetup.py -k $schema  -g $organism -f ~/datasets/mapping/$schema;;
	*)	echo "SchemaDatasetSetup.py skipped";;
esac

case "$type_2" in
	1)	echo "########## ~/script/shell/SchemaPreSetup.sh $organism $schema 1111111 ######"
		~/script/shell/SchemaPreSetup.sh $organism $schema 1111111;;
	*)	echo "SchemaPreSetup.sh skipped";;
esac

case "$type_3" in
	1)	echo "########## ssh ~/script/shell/graph_merge.sh $min_support $schema 1111 #######"
		ssh ~/script/shell/graph_merge.sh $min_support $schema 2111;;
	2)	echo "########## ~/script/shell/graph_merge.sh $min_support $schema 1211 #######"
		~/script/shell/graph_merge.sh $min_support $schema 1211;;
	3)	echo "########## ~/script/shell/graph_merge.sh $min_support $schema 3211 #######"
		~/script/shell/graph_merge.sh $min_support $schema 3211;;
	*)	echo "graph_merge.sh skipped";;
esac

case "$type_4" in
	1)	echo "########## ~/script/shell/netmine.sh $schema\g1e3d40q50s200c50z0001c8 $schema 2 220 -e3 -q0.5 -z0001 -t corTable0.8 ########"
		~/script/shell/netmine.sh $schema\g1e3d40q50s200c50z0001c8 $schema 2 220 0.6 -e3 -q0.5 -z0001 -t corTable0.8;;
	2)	echo "########## ~/script/shell/fim_wrapper.sh $schema $min_support 200 1111 0.6######"
		~/script/shell/fim_wrapper.sh $schema $min_support 200 1111 0.6;;
	*)	echo "netmine.sh or fim_wrapper.sh skipped";;
esac
