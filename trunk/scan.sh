#!/bin/sh

if test $# -lt 1
then
	echo "Usage:"
	echo "    scan.sh output_fname parameter_binary_code"
	echo
	echo " This program scans the pages(400dpi) one by one and"
	echo "concatenates them all together into one pdf/ps file."
	echo
	echo "parameter_binary_code controls which part to turn on."
	echo "Each digit means"
	echo "  1st. 1-> rotate the page 90 degrees counter-clockwise into letter-landscape"
	echo "  2nd. scan mode, default->Lineart, 1->Gray, 2->Color"
	exit
fi

output_fname=$1
parameter_binary_code=$2
need_rotate=`echo $parameter_binary_code|awk '{print substr($0,1,1)}'`
scan_mode=`echo $parameter_binary_code|awk '{print substr($0,2,1)}'`

i=0
yes_or_no='y'
resolution_dpi=400

echo -n "ready to scan:(y/n)?"
read yes_or_no

if test -z $yes_or_no
then
	echo
else
	exit 1
fi

outputf_ls=''
while true; do
	echo No. $i
	outputf=/tmp/output$i.pnm
	outputf_r=/tmp/output$i\_r.pnm
	case "$type_1" in
		1)	scanimage -x 215 -y 280 --resolution $resolution_dpi --mode Gray > $outputf;;
		2)	scanimage -x 215 -y 280 --resolution $resolution_dpi --mode Color > $outputf;;
		*)	scanimage -x 215 -y 280 --resolution $resolution_dpi --mode Lineart > $outputf;;
	esac
	
	if [ $need_rotate = "1" ]
	then
		unpaper --overwrite --pre-rotate -90 -s letter-landscape $outputf $outputf_r
	else
		unpaper --overwrite -s letter $outputf $outputf_r
	fi
	
	outputf_ls=`echo "$outputf_ls $outputf_r"`
	echo -n "press any key to continue or press 'n' to discontinue: "
	read yes_or_no
	if test -z $yes_or_no
	then
		i=`expr $i + 1`
	else
		break
	fi
done

output_prefix=`echo $output_fname|cut -d . -f 1`
convert $outputf_ls $output_prefix.ps
convert $outputf_ls $output_fname
rm $outputf_ls