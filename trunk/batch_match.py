#!/usr/bin/env python
"""
Usage: batch_match.py machinefile inputdir outputdir profile_filename

Examples:
	

Description:	
	11-14-05 program to run TRANSFAC match in parallel
	11-15-05 If more jobs than machines, other jobs have to wait for the 1st
	previous job to finish(a stupid queue, not the 1st finished job).
"""

import os, sys 

def init_job_on_that_machine(machine, inputdir, inputfiles, outputdir, match_bin_path, matrix_path, profile_filename):
	inputfilename = inputfiles.pop()
	inputfile = os.path.join(inputdir, inputfilename)
	outputfile = os.path.join(outputdir, '%s.out'%inputfilename)
	job_ls = ['ssh', machine, match_bin_path, matrix_path, inputfile, outputfile, profile_filename]
	pid = os.spawnvp(os.P_NOWAIT,'ssh', job_ls)
	sys.stderr.write("%s dispatched\n"%inputfile)
	return pid

if __name__ == '__main__':
	if len(sys.argv)<5:
		print __doc__
		sys.exit(3)

	machinefile, inputdir, outputdir, profile_filename = sys.argv[1:]
	
	#read other machines from machinefile
	machinef = open(machinefile)
	machine_ls = []
	for line in machinef:
		machine_name = line[:-1]
		machine_ls.append(machine_name)
		sys.stderr.write("%s added to machine_ls.\n"%machine_name)
	"""
	#11-15-05 not necessary, this_machine_hostname is the first one in machinefile
	#get the hostname for this machine and append it to the last
	this_machine_hostname = os.popen('hostname')
	this_machine_hostname = this_machine_hostname.read()[:-1]
	machine_ls.append(this_machine_hostname)
	"""
	no_of_machines = len(machine_ls)
	
	#create outputdir if not present
	if not os.path.isdir(outputdir):
		os.makedirs(outputdir)
	#start each job and store the pid in child_pid_list
	match_bin_path = '~/script/transfac/bin/match'
	matrix_path = '~/script/transfac/data/matrix.dat'
	machine2child_pid_ls = []
	inputfiles = os.listdir(inputdir)
	for machine in machine_ls:
		if len(inputfiles)>0:	#check if there's more inputfile
			pid = init_job_on_that_machine(machine, inputdir, inputfiles, outputdir, match_bin_path, matrix_path, profile_filename)
			machine2child_pid_ls.append([machine, pid])

	#wait for each child to end and recycle
	while machine2child_pid_ls:
		machine,pid = machine2child_pid_ls.pop(0)
		status = os.waitpid(pid, 0)
		sys.stderr.write("%s return status: %s\n"%(pid, status))
		if len(inputfiles)>0:
			pid = init_job_on_that_machine(machine, inputdir, inputfiles, outputdir, match_bin_path, matrix_path, profile_filename)
			machine2child_pid_ls.append([machine, pid])
