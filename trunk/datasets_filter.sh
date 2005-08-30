#!/bin/sh
if test $# -ne 4
then
	echo "Usage:"
	echo "    datasets_filter.sh input_dir geo_threshold smd_threshold RUNCODE"
	echo 
	echo " input_dir is the relative path in ~/datasets/, no '/'"
	echo " geo_threshold is for GEO datasets"
	echo " smd_threshold is for SMD datasets"
	echo
	echo " RUNCODE: 1 LogAffyDatasets.py (GEO), 2 LogAffyDatasets.py (SMD)"
	echo " 3 MergeGenes.py, 4 MpiGraphModeling.py"
	echo " For MpiGraphModeling.py: 1 is qsub, 2 is 20 nodes hostfile"
	echo
	exit
fi

inputdir=$1
geo_threshold=$2
smd_threshold=$3
runcode=$4
geo_threshold_int=`echo $geo_threshold |awk '{print $0*100}'`
smd_threshold_int=`echo $smd_threshold |awk '{print $0*100}'`
outputdirname_log=$inputdir\_s$geo_threshold_int\_smd_s$smd_threshold_int
outputdirname_merge=$outputdirname_log\_merged

input_dir=~/datasets/$inputdir
outputdir_log=~/datasets/$outputdirname_log
outputdir_merge=~/datasets/$outputdirname_merge
gph_dir=~/gph_result/$outputdirname_merge\_t1

type_1=`echo $runcode|awk '{print substr($0,1,1)}'`	#{} is a must.
type_2=`echo $runcode|awk '{print substr($0,2,1)}'`
type_3=`echo $runcode|awk '{print substr($0,3,1)}'`
type_4=`echo $runcode|awk '{print substr($0,4,1)}'`

#the python library path
source ~/.bash_profile
date

case "$type_1" in
	1)	echo ~/script/annot/bin/LogAffyDatasets.py -o $outputdir_log -s $geo_threshold -y1 $input_dir/GDS*
		~/script/annot/bin/LogAffyDatasets.py -o $outputdir_log -s $geo_threshold -y1 $input_dir/GDS*;;
	*)	echo "LogAffyDatasets.py (GEO) is skipped";;
esac
date


case "$type_2" in
	1)	echo ~/script/annot/bin/LogAffyDatasets.py -o $outputdir_log -s $smd_threshold -y2 $input_dir/*smd*
		~/script/annot/bin/LogAffyDatasets.py -o $outputdir_log -s $smd_threshold -y2 $input_dir/*smd*;;
	*)	echo "LogAffyDatasets.py (SMD) skipped";;
esac
date

case "$type_3" in
	1)	echo ~/script/annot/bin/MergeGenes.py -o $outputdir_merge $outputdir_log/*
		~/script/annot/bin/MergeGenes.py -o $outputdir_merge $outputdir_log/*;;
	*)	echo MergeGenes.py skiped;;
esac
date


case "$type_4" in
	1)	echo mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiGraphModeling.py -i $outputdir_merge -o $gph_dir -p 0 -c 0 -l
		mpirun.mpich -np $NHOSTS -machinefile $TMPDIR/machines /usr/bin/mpipython ~/script/annot/bin/MpiGraphModeling.py -i $outputdir_merge -o $gph_dir -p 0 -c 0 -l;;
	2)	echo mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiGraphModeling.py -i $outputdir_merge -o $gph_dir -p 0 -c 0 -l
		mpirun.mpich -np 20 -machinefile ~/hostfile /usr/bin/mpipython ~/script/annot/bin/MpiGraphModeling.py -i $outputdir_merge -o $gph_dir -p 0 -c 0 -l;;
	*)	echo "MpiGraphModeling.py skipped";;
esac

date
