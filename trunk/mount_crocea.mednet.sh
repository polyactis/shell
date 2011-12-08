#!/bin/sh
#sshfs -o reconnect yuhuang@hpc-cmb:/home/cmbpanfs-01/yuhuang ~/mnt/panfs/
#sshfs -o reconnect yuhuang@hpc-cmb:./ ~/mnt/hpc-cmb/

sshfs -o workaround=rename  -p 1999 crocea@uclaOffice:/ ~/mnt/crocea.mednet/
