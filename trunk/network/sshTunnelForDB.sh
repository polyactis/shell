#!/bin/bash
# to add a tunnel on hoffman2 slave nodes so that they could access psql db server on dl324b-1.cmb.usc.edu
# 2012.4.16 be careful of not running too many tunnels (>100s) through the same machine, the number of sshd processes for one user on each machine is limited. Will reject user login after that limit.
source ~/.bash_profile

tunnelNodeDefault=login1
tunnelNode=$1
if [ -z $tunnelNode ]
then
        tunnelNode=$tunnelNodeDefault
fi
targetHost=dl324b-1.cmb.usc.edu
targetHost=crocea.mednet.ucla.edu
targetPort=5432	#2012.11.4 for a short time, it was 443.
echo "ssh -N -f -L 5432:$targetHost:$targetPort polyacti@$tunnelNode"
ssh -N -L 5432:$targetHost:$targetPort polyacti@$tunnelNode & 
#return the ssh process ID. "-f" won't let $! capture the right ID. must use &.
tunnelProcessID=$!
echo tunnelProcessID: $tunnelProcessID
