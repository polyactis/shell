#!/bin/bash
# to add a tunnel on hoffman2 slave nodes so that they could access psql db server on dl324b-1.cmb.usc.edu

echo "ssh -N -f -L 5432:dl324b-1.cmb.usc.edu:5432 polyacti@login3"
ssh -N -f -L 5432:dl324b-1.cmb.usc.edu:5432 polyacti@login3
