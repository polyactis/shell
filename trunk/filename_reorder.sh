#!/bin/bash

echo "Warning: Before starting to rename the files,"
echo "Warning: you should keep in mind the new filenames set"
echo "Warning: should not overlap with the old filenames set."
echo "Warning: Otherwise, file loss may happen."
echo "Warning: The number of files within the folder <= 9999."
echo "Warning: The new file suffix is .jpg. Will offer option in future."
echo -n "Please enter the current prefix for all these files: "
read oldPrefix
echo -n "Please enter the new prefix for all these files: "
read prefix
echo -n "Enter the base number: "
read base
echo -n "What is the increasing unit, 1 or 2?"
read unit
page=$base
count=$page

cd  $1

echo -n "Current working directory is: "
pwd
echo -n "Continue? (y/n): "
read answer

if [ $answer = 'y' ]
then

	for i in `ls $oldPrefix*`
	do
		if test -w $i
		then
			if `test -f $i`
			then
				if [ $page -lt 10 ]
				then
					page=000$page
				elif [ $page -lt 100 ]
				then
					page=00$page
				elif [ $page -lt 1000 ]
				then
					page=0$page
				fi
				mv -i $i $prefix\_$page\.jpg
				page=`expr $page \+ $unit`
				count=`expr $count \+ 1`
			fi
		fi
	done

else
	echo "you answered no"
fi

echo `expr $count \- $base` "filenames reordered"
