#!/bin/sh
if test $# -ne 1
then
	echo "Usage:"
	echo "  RemoveTop100OldFile.sh INPUT_DIR"
	echo ""
	echo "Remove the top 100 oldest files in INPUT_DIR"
	echo
	exit
fi
input_dir=$1
i=0
for file in `ls -tr $input_dir`; do
	i=`echo $i+1|bc`
	if [ $i = "101" ]; then
		break
	else
		file=$input_dir/$file
		echo $i $file
		rm $file
	fi
done
