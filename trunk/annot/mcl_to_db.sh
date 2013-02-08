#!/bin/sh
date
~/script/annot/bin/mcl_to_db.py -k $1 -t $2 -c $3
date
