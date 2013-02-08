#!/bin/sh

if test $# -ne 1
then
	echo "Usage:"
	echo "    clustering_test.sh GSPAN_INPUT_FILE"
	echo
	echo "This is a script call clustering_test.py to reformat gspan"
	echo "file into matrix format for copath."
	exit
fi
					

gspan_input_file=$1
matrix_file=$gspan_input_file.matrix
#the python library path
source ~/.bash_profile
date

echo ~/script/annot/bin/visualize/clustering_test.py -i $gspan_input_file -y1 -o $matrix_file
~/script/annot/bin/visualize/clustering_test.py -i $gspan_input_file -y1 -o $matrix_file

date

