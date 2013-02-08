#!/bin/sh
#sshfs -o reconnect yuhuang@hpc-cmb:/home/cmbpanfs-01/yuhuang ~/mnt/panfs/
#sshfs -o reconnect yuhuang@hpc-cmb:./ ~/mnt/hpc-cmb/

sshfs -o workaround=rename yuhuang@hpc-login2.usc.edu:/home/cmbpanfs-01/yuhuang ~/mnt/panfs/
sshfs -o workaround=rename yuhuang@hpc-login2.usc.edu:/ ~/mnt/hpc-cmb/
sshfs -o workaround=rename yuhuang@hpc-login2.usc.edu:/auto/cmb-03/mn/yuhuang ~/mnt/hpc-cmb_home/
