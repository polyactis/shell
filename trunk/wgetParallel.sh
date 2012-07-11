#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -o $JOB_NAME.joblog.$JOB_ID
#$ -j y
#$ -l time=200:00:00
#$ -l highp
#$ -r y
#$ -V

if test $# -lt 5
then
        echo "Usage: $0 USERNAME PASSWORD URL FILEWithToBeDownloadedFilenames TARGETDIR "
        echo
        echo
	echo "This script calls wget to download every files within specific URL (no sub-folders) into target dir."
	echo "Each file will be downloaded by one background wget process."
	echo "The TARGETDIR will be made regardless of its existence."
	echo
        echo "Examples: "
	echo "  $0 someone secret https://xfer.edu/gxfer2/ filesToBeDownloaded.txt genomeData/"
exit
fi


username=$1
password=$2
URL=$3
FILEWithToBeDownloadedFilenames=$4
targetSubDir=$5
mkdirhier $targetSubDir

for i in `cat $FILEWithToBeDownloadedFilenames`;
	do echo $i;
	wget --user=$username --password=$password --recursive --no-parent --continue --reject='index.html*' $URL/$i --background -nd -P $targetSubDir -nH --cut-dirs=1;
done

# However, unlike -nd, --cut-dirs does not lose with subdirectories---for instance, with
# -nH --cut-dirs=1, a beta/ subdirectory will be placed to xemacs/beta, as one would expect.
