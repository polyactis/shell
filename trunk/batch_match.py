#!/usr/bin/env python
"""
Usage: batch_match.py machinefile inputdir outputdir profile_filename

Examples:
	

Description:	
	11-14-05 program to run TRANSFAC match in parallel
	
"""

import os, sys, csv
if len(sys.argv)<5:
	print __doc__
	sys.exit(3)

machinefile, inputdir, outputdir, profile_filename = sys.argv[1:]

#read other machines from machinefile
machinef = csv.reader(open(machinefile), delimiter=' ')
machine_ls = []
for row in machinef:
	machine_ls.append(row[0])
#get the hostname for this machine and append it to the last
this_machine_hostname = os.popen('hostname')
this_machine_hostname = this_machine_hostname.read()[:-1]
machine_ls.append(this_machine_hostname)

#create outputdir if not present
if not os.path.isdir(outputdir):
	os.makedirs(outputdir)
#start each job and store the pid in child_pid_list WATCH: machine_ls must be >= inputfiles
match_bin_path = '~/script/transfac/bin/match'
matrix_path = '~/script/transfac/data/matrix.dat'
child_pid_list = []
inputfiles = os.listdir(inputdir)
for i in range(len(inputfiles)):
	inputfile = os.path.join(inputdir, inputfiles[i])
	outputfile = os.path.join(outputdir, '%s.out'%inputfiles[i])
	pid = os.spawnvp(os.P_NOWAIT,'ssh', ['ssh', machine_ls[i], \
		match_bin_path, matrix_path, inputfile, outputfile, profile_filename])
	print "%s dispatched"%inputfile
	child_pid_list.append(pid)
#wait for each child to end
for pid in child_pid_list:
	status = os.waitpid(pid, 0)
	print pid,"return status:",status
