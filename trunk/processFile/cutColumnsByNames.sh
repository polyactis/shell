#!/bin/bash

pageNumberIncreasingStepDefault=2
newFileSuffixDefault=.jpg
if test $# -lt 2 ; then
	echo "  $0 inputFname delimiter column1Name [column2Name] ..."
	echo ""
	echo "Note:"
	echo "	1. This program find columns by their names (headers) and displays the values of chosen columns. "
	echo " 	2. if the delimiter is tab, put 'tab' there. For single-space or other character , put it as it is."
	echo
	echo "Examples:"
	echo "	$0 method_36_Contig791_replicated_phasedByGATK.vcf tab 1511_639_1987079_GA_vs_524copy3 1016_725_1995116_GA_vs_524copy7"
	exit 1
fi

inputFname="$1"
delimiter="$2"
if test z"$delimiter" = "z"; then
	echo delimiter is set to single-space.
	delimiter=' '
fi
echo delimiter is "$delimiter".
shift
shift
columnNames="$*"

columnIndices=""
for columnHeader in $columnNames; do
	echo -n "index for column $columnHeader is "
	if test "$delimiter" = "tab"; then
		columnIndex=`awk -F "\t" '{for (i=1;i<NF;i++) {if ($i=="'$columnHeader'") {print i}} }' $inputFname`
	else
		columnIndex=`awk -F "$delimiter" '{for (i=1;i<NF;i++) {if ($i=="'$columnHeader'") {print i}} }' $inputFname`
	fi
	columnIndex=`echo $columnIndex|tr " " ","`
	echo $columnIndex
	if test -z $columnIndices; then
		columnIndices=$columnIndex
	else
		columnIndices=$columnIndices,$columnIndex
	fi
done
columnIndicesSplitByComma=$columnIndices
#columnIndicesSplitByComma=`echo $columnIndices | tr "\n" ","`
#strLength=`expr length $columnIndicesSplitByComma`
#echo columnIndicesSplitByComma length is $strLength
#strLengthMinus1=`echo $strLength-1|bc`
#echo strLengthMinus1 is $strLengthMinus1
#echo index for $columnNames is $columnIndicesSplitByComma
#columnIndicesSplitByComma=`expr substr $columnIndicesSplitByComma 1 $strLengthMinus1`

echo index for $columnNames is $columnIndicesSplitByComma
#echo $columnNames
if test "$delimiter" = "tab"; then
	cut -f $columnIndicesSplitByComma $inputFname
else
	cut -d "$delimiter" -f $columnIndicesSplitByComma $inputFname
fi
#echo $commandline
#$commandline
