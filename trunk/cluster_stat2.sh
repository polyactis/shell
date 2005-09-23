#!/bin/sh

if test $# -lt 4
then
	echo "Usage:"
	echo "    cluster_stat2.sh SCHEMA INPUT_FILE RUNCODE ACC_CUTOFF"
	echo
	echo "This is a script linking all stat programs"
	echo
	echo "RUNCODE controls which part to turn on"
	echo " 1.p_gene_lm/p_gene_analysis 2.gene_p_map_redundancy"
	echo " 3.filter.sh"
	echo 
	echo " 1st digit: 1(p_gene_lm + p_gene_analysis)"
	echo "   2(p_gene_analysis)"
	echo " 3rd digit: 1(qsub), 2(direct run)"
	exit
fi

schema=$1
input_file=$2
runcode=$3
acc_cutoff=$4

type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`

splat_result_table=splat_$input_file
mcl_result_table=mcl_$input_file
cluster_stat_table=/scratch/00/yuhuang/cluster_stat/cluster_$input_file
p_gene_table=p_gene_$input_file\_e5
acc_int=`echo $acc_cutoff|awk '{print $0*100}'`
lm_table=lm_$input_file\_e5_a$acc_int
gene_p_table=gene_p_$input_file\_e5_a$acc_int


echo " RUNCODE is $runcode "


#the python library path
source ~/.bash_profile

date

case "$type_1" in
	1)	echo ssh node27 ~/script/shell/p_gene_lm.sh $schema $input_file $acc_cutoff
		ssh node27 ~/script/shell/p_gene_lm.sh $schema $input_file $acc_cutoff
		#p_gene_lm calls rpy.r, which is banned by qsub. run it elsewhere
		echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0 -l $lm_table -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0 -l $lm_table -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	2)	echo ~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out
		~/script/annot/bin/p_gene_analysis.py -k $schema -t $splat_result_table -p 0.01 -c -j 2  -g $p_gene_table -n $gene_p_table ~/p_gene_analysis/$gene_p_table.out;;
	*)	echo "No p_gene_analysis and/or p_gene_lm";;
esac

date

if [ $type_2 = "1" ]; then
	echo ~/script/annot/bin/gene_p_map_redundancy.py -k $schema -t $p_gene_table -n $gene_p_table -c
	~/script/annot/bin/gene_p_map_redundancy.py -k $schema -t $p_gene_table -n $gene_p_table -c
fi

date

case "$type_1" in
	1)	echo ~/script/shell/filter.sh $schema $input_file $acc_cutoff 11
		~/script/shell/filter.sh $schema $input_file $acc_cutoff 11;;
	2)	echo ~/script/shell/filter.sh $schema $input_file $acc_cutoff 22
		~/script/shell/filter.sh $schema $input_file $acc_cutoff 22;;
	*)	echo "filter.sh skipped";;	
esac

#echo ~/script/annot/bin/connectivity_original.py -k $schema -c -t $mcl_result_table
#~/script/annot/bin/connectivity_original.py -k $schema -c -t $mcl_result_table

date
