#!/bin/bash - 
#$ -V
#$ -b y
#$ -cwd
#$ -l h_data=4G,time=330:00:00,highp

if test $# -lt 2 ; then
	echo "  $0 inputFolder outputFile"
	echo ""
	echo "Note:"
	echo "	inputFolder is the one to be backed-up."
	echo "	outputFile is the gzip file to store the backup, in the form of x.tar.gz."
	echo ""
	echo "Examples:"
	echo "	$0 ~/Data ~/Data.tar.gz"
	echo "	$0 ~/panasas/Data ~/Data.tar.gz"
	exit 1
fi
date
set -e
source error_handling
script_start

inputFolder=$1
outputFile=$2

tar -h -cpzf $outputFile $inputFolder
#h - --dereference. follow symlinks; archive and dump the files they point to
#c - create a new backup archive.
#v - verbose mode, tar will print what it's doing to the screen.
#p - preserves the permissions of the files put in the archive for restoration later.
#z - compress the backup file with 'gzip' to make it smaller.
#f <filename> - specifies where to store the backup, backup.tar.gz is the filename used in this example. It will be stored in the current working directory, the one you set when you used the cd command.

script_end
date
