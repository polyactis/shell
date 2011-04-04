#!/bin/sh
#sshfs -o reconnect yuhuang@hpc-cmb:/home/cmbpanfs-01/yuhuang ~/mnt/panfs/
#sshfs -o reconnect yuhuang@hpc-cmb:./ ~/mnt/hpc-cmb/

sshfs -o workaround=rename polyacti@hoffman2.idre.ucla.edu:/ ~/mnt/hoffman2
sshfs -o workaround=rename polyacti@hoffman2.idre.ucla.edu:./ ~/mnt/hoffman2_home
