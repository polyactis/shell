#!/bin/sh

partialWordDefault=0
runTypeDefault=0
if test $# -lt 4 ; then
	echo
	echo "Usage: $0 inputFolder inputFileNamePattern oldTextPattern newTextPattern [partialWord] [runType]"
	echo ""
	echo "Note:"
	echo "	#. This program finds all input files given inputFileNamePattern in inputFolder,"
	echo "	  and then replaces the oldTextPattern in each of those files with newTextPattern."
	echo "	#. The text substitution is done by sed exhaustively (s/\b$oldTextPattern\b/.../g by default, s/$oldTextPattern/.../g if partialWord)."
	echo "	#. It generates a FILEPATH.tmp file to hold the new content for each FILEPATH."
	echo "	#. If partialWord is 1, then oldTextPattern is matched without whole-word constraint. A word with partial match will be substituted too."
	echo "	#. 	Default of partialWord is $partialWordDefault."
	echo "	#. If runType is 0, this program leaves the new content in FILEPATH.tmp but do not overwrite the original one."
	echo "	#. If runType is 1, this program will actually overwrite the original FILEPATH with FILEPATH.tmp."
	echo "	#. If runType is 2, this program deletes FILEPATH.tmp left by runType 0."
	echo "	#. Default runType is $runTypeDefault."
	echo
	echo "Examples:"
	echo "	# whole-word substitution."
	echo "	$0 pymodule/ \"*.py\" dataDir data_dir"
	echo 
	echo "	# delete the .tmp files"
	echo "	$0 pymodule/ \"*.py\" dataDir data_dir 0 2"
	echo
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
if [ -z $partialWord ]
then
	partialWord=$partialWordDefault
fi

runType=$6
if [ -z $runType ]
then
	runType=$runTypeDefault
fi
echo "partialWord is $partialWord."
echo "runType is $runType."

# 2013.2.8 add -maxdepth 1 to find if you only wants the command to reach current level of folder, not further subfolders. 
filesWithMatchingNames=`find $inputFolder/ -name $inputFileNamePattern`
if [ -z "$filesWithMatchingNames" ]; then
	echo "No files matching $inputFileNamePattern in $inputFolder."
	exit 1
fi

if test "$partialWord" = "1" ; then
	affectedFiles=`grep -l $oldTextPattern $filesWithMatchingNames`
else
	affectedFiles=`grep -w -l $oldTextPattern $filesWithMatchingNames`
fi


if test "$runType" = "1"; then
	echo "These files have matches: \n$affectedFiles"
	echo "File overwriting option is on."
	echo -n "Continue? (y/n): "
	read answer
	if [ $answer != 'y' ]; then
		exit 1
	fi
fi

if [ -n "$affectedFiles" ]; then
	for f in $affectedFiles; do
		echo $f
		#added g in the end to make it exhaustive (replace every instances in one line, rather than 1st instance)
		cp -ap $f $f.tmp	#to preserve the properties of the old file
		if test "$partialWord" = "1" ; then
			sed 's/'$oldTextPattern'/'$newTextPattern'/g' $f > $f.tmp;
		else
			sed 's/\b'$oldTextPattern'\b/'$newTextPattern'/g' $f > $f.tmp;
		fi
		
		if test "$runType" = "1"; then
			mv $f.tmp $f
		elif test "$runType" = "2"; then
			rm $f.tmp
		fi
	done
fi