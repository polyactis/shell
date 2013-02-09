#!/bin/sh

partialWordDefault=0
if test $# -lt 4 ; then
	echo
	echo "Usage: $0 inputFolder inputFileNamePattern oldTextPattern newTextPattern [partialWord] [commit]"
	echo ""
	echo "Note:"
	echo "	#. This program finds all input files given inputFileNamePattern in inputFolder,"
	echo "	  and then replaces the oldTextPattern in each of those files with newTextPattern."
	echo "	#. The text substitution is done by sed exhaustively (s/\b$oldTextPattern\b/.../g by default, s/$oldTextPattern/.../g if partialWord)."
	echo "	#. It generates a FILEPATH.tmp file to hold the new content for each FILEPATH."
	echo "	#. If partialWord is 1, then oldTextPattern is matched without whole-word constraint. A word with partial match will be substituted too."
	echo "	#. 	Default of partialWord is $partialWordDefault."
	echo "	#. If commit is not empty (anything), this program will actually overwrite the original FILEPATH with FILEPATH.tmp."
	echo
	echo "Examples:"
	echo "	# whole-word substitution."
	echo "	$0 pymodule/ \"*.py\" dataDir data_dir"
	echo "	#check the .tmp files to see if things were done properly, if yes, do this."
	echo "	$0 pymodule/ \"*.py\" dataDir data_dir 0 1"
	echo "	#partial word substitution"
	echo "	$0 pymodule/ \"*.py\" dataDir data_dir 1"
	echo
	exit 1
fi

inputFolder=$1
inputFileNamePattern=$2
oldTextPattern=$3
newTextPattern=$4
partialWord=$5
commit=$6
echo "partialWord is $partialWord."
echo "commit is $commit."

if test "$partialWord" = "1" ; then
	affectedFiles=`grep -w -l $oldTextPattern \`find $inputFolder/ -name $inputFileNamePattern\``
else
	affectedFiles=`grep -l $oldTextPattern \`find $inputFolder/ -name $inputFileNamePattern\``
fi


if [ -n "$commit" ]; then
	echo "These files have matches: \n$affectedFiles"
	echo "File overwriting option is on."
	echo -n "Continue? (y/n): "
	read answer
	if [ $answer != 'y' ]; then
		exit 1
	fi
fi

for f in $affectedFiles; do
	echo $f
	#added g in the end to make it exhaustive (replace every instances in one line, rather than 1st instance)
	if test "$partialWord" = "1" ; then
		sed 's/'$oldTextPattern'/'$newTextPattern'/g' $f > $f.tmp;
	else
		sed 's/\b'$oldTextPattern'\b/'$newTextPattern'/g' $f > $f.tmp;
	fi
	
	if [ -n "$commit" ]
	then
		mv $f.tmp $f
	fi
done
