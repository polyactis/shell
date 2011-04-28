#!/bin/sh
#sshfs -o reconnect yuhuang@hpc-cmb:/home/cmbpanfs-01/yuhuang ~/mnt/panfs/
#sshfs -o reconnect yuhuang@hpc-cmb:./ ~/mnt/hpc-cmb/

sshfs -o workaround=rename yuhuang@hpc-cmb.usc.edu:/home/cmbpanfs-01/yuhuang ~/mnt/panfs/
sshfs -o workaround=rename yuhuang@hpc-cmb.usc.edu:./ ~/mnt/hpc-cmb/
