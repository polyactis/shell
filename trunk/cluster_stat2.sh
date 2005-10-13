#!/bin/sh

if test $# -lt 5
then
	echo "Usage:"
	echo "    cluster_stat2.sh SCHEMA INPUT_FILE LM_BIT ACC_CUTOFF RUNCODE"
	echo
	echo "This is a script linking all stat programs"
	echo
	echo "RUNCODE controls which part to turn on"
	echo " 1.p_gene_lm 2.p_gene_analysis"
	echo " 3.gene_p_map_redundancy 4.filter.sh"
	echo 
	echo " 2nd digit: 1(from lm_table)"
	echo "   2(p_value 0.01) 3(p_value 1)"
	echo " 4th digit: 1(qsub), 2(direct run)"
	exit
fi

schema=$1
input_file=$2
lm_bit=$3
acc_cutoff=$4
runcode=$5

type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`

splat_result_table=splat_$input_file
mcl_result_table=mcl_$input_file
cluster_stat_table=/scratch/00/yuhuang/cluster_stat/cluster_$input_file
p_gene_table=p_gene_$input_file\_e5

#other scripts don't process ACC_CUTOFF or LM_BIT
acc_int=`echo $acc_cutoff|awk '{print $0*100}'`
if [ $lm_bit = "111" ]; then
	lm_suffix=$input_file\_e5_a$acc_int	#backward compatible
else
	lm_suffix=$input_file\_e5_$lm_bit\a$acc_int
fi
lm_table=lm_$lm_suffix
gene_p_table=gene_p_$lm_suffix


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

case "$type_1" in
	1)	echo ssh $HOSTNAME ~/script/shell/p_gene_lm.sh $schema $input_file $lm_bit $acc_cutoff
		ssh $HOSTNAME ~/script/shell/p_gene_lm.sh $schema $input_file $lm_bit $acc_cutoff;;
	*)	echo "No p_gene_lm.sh";;
esac

check_exit_status

case "$type_2" in
	1)	echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0 -l $lm_table -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0 -l $lm_table -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	2)	echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	3)	echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 1 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 1 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	*)	echo "No p_gene_analysis.py";;

esac

check_exit_status


if [ $type_3 = "1" ]; then
	echo ~/script/annot/bin/gene_p_map_redundancy.py -k $schema -t $p_gene_table -n $gene_p_table -c
	~/script/annot/bin/gene_p_map_redundancy.py -k $schema -t $p_gene_table -n $gene_p_table -c
fi

check_exit_status

case "$type_4" in
	1)	echo ~/script/shell/filter.sh $schema $input_file $lm_bit $acc_cutoff 11
		~/script/shell/filter.sh $schema $input_file $lm_bit $acc_cutoff 11;;
	2)	echo ~/script/shell/filter.sh $schema $input_file $lm_bit $acc_cutoff 22
		~/script/shell/filter.sh $schema $input_file $lm_bit $acc_cutoff 22;;
	*)	echo "filter.sh skipped";;	
esac

#echo ~/script/annot/bin/connectivity_original.py -k $schema -c -t $mcl_result_table
#~/script/annot/bin/connectivity_original.py -k $schema -c -t $mcl_result_table

check_exit_status
