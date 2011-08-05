#!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -o $JOB_NAME.joblog.$JOB_ID
#$ -j y
#$ -l time=200:00:00
#$ -l highp
#$ -r y
#$ -V
source ~/.bash_profile

cd ~/script/vervet/data/VRC

username=$1
password=$2
URL=$3

#wget --no-check-certificate --user=ahcoomeineim --password=oiziakohfuuk --recursive --no-parent --continue --reject='index.html*'   https://xfer.genome.wustl.edu/gxfer2/58214230260728/
echo wget --no-check-certificate --user=$username --password=$password --recursive --no-parent --continue --reject='index.html*'  $URL
wget --no-check-certificate --user=$username --password=$password --recursive --no-parent --continue --reject='index.html*'  $URL
