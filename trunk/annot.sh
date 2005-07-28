#!/bin/sh
if test $# -ne 1
then
	echo "Usage:"
	echo "   annot.sh SCHEMA"
	echo ""
	echo "final script links SchemaDatasetSetup.py, SchemaPreSetup.sh, graph_merge.sh, netmine.sh"
	echo
	exit
fi
schema=$1

echo ########## ~/script/shell/SchemaDatasetSetup.py -k $schema  -g mm -f ~/datasets/mapping/$schema ##########
~/script/shell/SchemaDatasetSetup.py -k $schema  -g mm -f ~/datasets/mapping/$schema
echo ########## ~/script/shell/SchemaPreSetup.sh mm $schema 1111111 ######
~/script/shell/SchemaPreSetup.sh mm $schema 1111111
echo ########## ~/script/shell/graph_merge.sh 2 $schema 1111 #######
~/script/shell/graph_merge.sh 2 $schema 1111
echo ########## ~/script/shell/netmine.sh $schema\g1e3d40q50s200c50z0001c8 $schema 2 220 -e3 -q0.5 -z0001 -t corTable0.8 ########
~/script/shell/netmine.sh $schema\g1e3d40q50s200c50z0001c8 $schema 2 220 0.6 -e3 -q0.5 -z0001 -t corTable0.8
