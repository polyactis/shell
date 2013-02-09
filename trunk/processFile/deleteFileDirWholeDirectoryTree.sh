#!/bin/sh
#
# Usage: deleteFileDirWholeDirectoryTree.sh ./ \\*.svn
# 
# double anti-slash is for escaping.
inputDir=$1
pattern=$2
for i in `find $inputDir -name $pattern`; do
	echo $i;
	#rm -rf $i
done
