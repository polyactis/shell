#!/bin/sh

if test $# -lt 5
then
	echo "Usage:"
	echo "    cluster_stat2.sh SCHEMA INPUT_FILE LM_BIT ACC_CUTOFF RUNCODE PARAMETERS"
	echo
	echo "This is a script linking all stat programs"
	echo
	echo "RUNCODE controls which part to turn on"
	echo "PARAMETERS are passed to rpart_prediction.py"
	echo
	echo " 1.rpart_prediction.py"
	echo " 2.p_gene_lm/OneParameterCutoffSeeker.py 3.p_gene_analysis"
	echo " 4.gene_p_map_redundancy 5.filter.sh"
	echo 
	echo "Each digit in RUNCODE:"
	echo
	echo "2:"
	echo " 1(p_gene_lm),2(OneParameterCutoffSeeker.py)"
	echo "3(p_gene_analysis.py):"
	echo "	  1(from lm_table) 2(p_value 0.01) 3(p_value 10000)"
	echo "5(filter.sh, only the 1st program, filter_clusters.py):"
	echo "   1(ssh node-self and run), 2(direct run)"
	exit
fi

schema=$1
input_file=$2
lm_bit=$3
acc_cutoff=$4
runcode=$5
parameter=''
while test -n "$6"
do
parameter=$parameter' '$6
shift
done

type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`
type_5=`echo $runcode|awk '{print substr($0,5,1)}'`

acc_int=`echo $acc_cutoff|awk '{print $0*100}'`

#02-01-06 copied from cluster_stat.sh
derive_tables() {
	splat_result_table=splat_$input_file
	mcl_result_table=mcl_$input_file
	pattern_table=pattern_$input_file #10-14-05
	cluster_stat_table=/scratch/00/yuhuang/cluster_stat/cluster_$input_file
	p_gene_table=p_gene_$input_file\_e5
	#other scripts don't process ACC_CUTOFF or LM_BIT
	if [ $lm_bit = "111" ]; then
		lm_suffix=$input_file\_e5_a$acc_int	#backward compatible
	else
		lm_suffix=$input_file\_e5_$lm_bit\a$acc_int
	fi
	lm_table=lm_$lm_suffix
	gene_p_table=gene_p_$lm_suffix
}

derive_tables



echo " RUNCODE is $runcode "

check_exit_status() {
	date
	return_code=$?
	if [ $return_code != "0" ]; then
		echo "Return code non-zero:"$return_code
		exit
	fi
}

#the python library path
source ~/.bash_profile

date

rpart_parameter=$parameter
new_input_file=$input_file`~/script/annot/bin/arguments2string.py $rpart_parameter`
echo "######## rpart_prediction.py ######"
case "$type_1" in
	1)	echo ssh $HOSTNAME ~/script/annot/bin/rpart_prediction.py -k $schema -i $input_file -j $new_input_file -c -u $rpart_parameter
		ssh $HOSTNAME ~/script/annot/bin/rpart_prediction.py -k $schema -i $input_file -j $new_input_file -c -u $rpart_parameter
		input_file=$new_input_file	#change input_file
		derive_tables;;
	*)	echo "rpart_prediction.py skipped";;
esac

check_exit_status

case "$type_2" in
	1)	echo ssh $HOSTNAME ~/script/shell/p_gene_lm.sh $schema $input_file $lm_bit $acc_cutoff
		ssh $HOSTNAME ~/script/shell/p_gene_lm.sh $schema $input_file $lm_bit $acc_cutoff;;
	2)	echo ssh $HOSTNAME ~/script/annot/bin/OneParameterCutoffSeeker.py -k $schema -t $p_gene_table -l $lm_table -a $acc_cutoff -w $lm_bit -c -j2
		ssh $HOSTNAME ~/script/annot/bin/OneParameterCutoffSeeker.py -k $schema -t $p_gene_table -l $lm_table -a $acc_cutoff -w $lm_bit -c -j2;;
	*)	echo "No p_gene_lm.sh/OneParameterCutoffSeeker.py";;
esac

check_exit_status

case "$type_3" in
	1)	echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0 -l $lm_table -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0 -l $lm_table -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	2)	echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	3)	echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 1 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 10000 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	*)	echo "No p_gene_analysis.py";;

esac

check_exit_status


if [ $type_4 = "1" ]; then
	echo ~/script/annot/bin/gene_p_map_redundancy.py -k $schema -t $p_gene_table -n $gene_p_table -c
	~/script/annot/bin/gene_p_map_redundancy.py -k $schema -t $p_gene_table -n $gene_p_table -c
fi

check_exit_status

case "$type_5" in
	1)	echo ~/script/shell/filter.sh $schema $input_file $lm_bit $acc_cutoff 10
		~/script/shell/filter.sh $schema $input_file $lm_bit $acc_cutoff 10;;
	2)	echo ~/script/shell/filter.sh $schema $input_file $lm_bit $acc_cutoff 20
		~/script/shell/filter.sh $schema $input_file $lm_bit $acc_cutoff 20;;
	*)	echo "filter.sh skipped";;	
esac

#echo ~/script/annot/bin/connectivity_original.py -k $schema -c -t $mcl_result_table
#~/script/annot/bin/connectivity_original.py -k $schema -c -t $mcl_result_table

check_exit_status
