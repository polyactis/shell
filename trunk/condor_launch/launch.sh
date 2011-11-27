#!/bin/bash

set -e
expirationInHours=$1
noOfCPUs=$2
condorHost=$3

if [ "x$condorHost" = "x" ]; then
	echo "No master host given - assuming I'm the new master!"
	CONDOR_HOST=`hostname -f`
	CONDOR_DAEMON_LIST="MASTER, COLLECTOR, NEGOTIATOR, STARTD, SCHEDD"
	echo "When registering workers, please specify $CONDOR_HOST as the central manager"
else
	echo "Starting worker for the master at $condorHost"
	CONDOR_HOST=$condorHost
	CONDOR_DAEMON_LIST="MASTER, STARTD"
fi


if [ "x$expirationInHours" = "x" ]; then
	echo "No expirationInHours given. set it to 24."
	expirationInHours=24;
else
	echo "expirationInHours set to $expirationInHours."
	expirationInHours=$expirationInHours
fi

expirationInMins=`echo whatever|awk '{print '$expirationInHours'*60}'`;
echo condor daemon will expire after $expirationInMins minutes.

if [ "x$noOfCPUs" = "x" ]; then
	echo "No noOfCPUs given. set it to \$(DETECTED_CORES)"
	noOfCPUs="\$(DETECTED_CORES)";
else
	echo "noOfCPUs set to $noOfCPUs."
fi

# condor folder to use
CONDOR=condor

# this will contain logs/execute/spool
currentUnixTime=`echo "import time; print time.time()"|python`
# 2011-11-26 stop attaching currentUnixTime to LOCAL_DIR. because it makes exporting CONDOR_CONFIG on master node complicated.
LOCAL_DIR=/work/polyacti/condor

#clean up the condor conf folder
rm -rf $LOCAL_DIR/*

TOP_DIR=`dirname $0`
TOP_DIR=`cd $TOP_DIR && pwd`

mkdir -p $LOCAL_DIR/execute
mkdir -p $LOCAL_DIR/log
mkdir -p $LOCAL_DIR/spool

# create an env file for easy sourcing
cat >$LOCAL_DIR/env.sh <<EOF
#!/bin/bash
export PATH=$TOP_DIR/$CONDOR/bin:$TOP_DIR/$CONDOR/sbin:$PATH
export CONDOR_CONFIG=$LOCAL_DIR/condor_config
EOF

. $LOCAL_DIR/env.sh

# fix the condor config file
cp $TOP_DIR/condor_config $TOP_DIR/condor_config.local $LOCAL_DIR/
perl -p -i -e "s:^RELEASE_DIR.*:RELEASE_DIR = $TOP_DIR/$CONDOR:" $LOCAL_DIR/condor_config
perl -p -i -e "s:^LOCAL_DIR( |\t).*:LOCAL_DIR = $LOCAL_DIR:" $LOCAL_DIR/condor_config

echo "NUM_CPUS=$noOfCPUs" >>$LOCAL_DIR/condor_config.local
echo "CONDOR_HOST=$CONDOR_HOST" >>$LOCAL_DIR/condor_config.local
echo "FILESYSTEM_DOMAIN=$CONDOR_HOST" >>$LOCAL_DIR/condor_config.local
echo "DAEMON_LIST=$CONDOR_DAEMON_LIST" >>$LOCAL_DIR/condor_config.local

condor_master -f -r $expirationInMins

#-f: Causes the daemon to start up in the foreground. Instead of forking, the daemon runs in the foreground.
#-r MINUTES: Causes the daemon to set a timer, upon expiration of which, it sends itself a SIGTERM for graceful shutdown.

