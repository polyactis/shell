#!/bin/sh
date
~/script/annot/bin/db_to_mcl.py -k $1 -t $2 -s $3 $4
date
