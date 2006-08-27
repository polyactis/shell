#!/usr/bin/env python
"""
Usage: batch_match.py machinefile inputdir outputdir profile_filename

Examples:
	-m ...,	machinefile
	-i ...,	inputdir
	-o ...,	outputdir
	-p ...,	profile_filename
	-g ...,	organism, for RepeatMasker ('human', default)
	-y ...,	running type, 1(just match, default), 2(frist RepeatMasker, 2nd match)

Description:	
	11-14-05 program to run TRANSFAC match in parallel
	11-15-05 If more jobs than machines, other jobs have to wait for the 1st
	previous job to finish(a stupid queue, not the 1st finished job).
	2006-08-25 $inputdir_masked is used for RepeatMasker
	
"""

import os, sys, getopt

class batch_match:
	"""
	2006-08-25
		make it a class and add RepeatMasker
	"""
	def __init__(self, machinefile, inputdir, outputdir, profile_filename, organism, type):
		self.machinefile = machinefile
		self.inputdir = inputdir
		self.outputdir = outputdir
		self.profile_filename = profile_filename
		self.organism = organism
		self.type = int(type)
	
	def get_all_machines(self, machinefile):
		"""
		2006-08-25
		"""
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
		return machine_ls

	
	def init_match_on_that_machine(self, machine, inputdir, inputfiles, outputdir, match_bin_path, matrix_path, profile_filename):
		"""
		2006-08-25
		"""
		inputfilename = inputfiles.pop()
		inputfile = os.path.join(inputdir, inputfilename)
		outputfile = os.path.join(outputdir, '%s.out'%inputfilename)
		job_ls = ['ssh', machine, match_bin_path, matrix_path, inputfile, outputfile, profile_filename]
		pid = os.spawnvp(os.P_NOWAIT,'ssh', job_ls)
		sys.stderr.write("%s dispatched\n"%inputfile)
		return pid
		
	def run_match(self, machine_ls, inputfiles, inputdir, outputdir, profile_filename):
		sys.stderr.write("Running match...\n")
		#create outputdir if not present
		if not os.path.isdir(outputdir):
			os.makedirs(outputdir)
		#start each job and store the pid in child_pid_list
		match_bin_path = '~/script/transfac/bin/match'
		matrix_path = '~/script/transfac/data/matrix.dat'
		machine2child_pid_ls = []
		for machine in machine_ls:
			if len(inputfiles)>0:	#check if there's more inputfile
				pid = self.init_match_on_that_machine(machine, inputdir, inputfiles, outputdir, match_bin_path, matrix_path, profile_filename)
				machine2child_pid_ls.append([machine, pid])
	
		#wait for each child to end and recycle
		while machine2child_pid_ls:
			machine,pid = machine2child_pid_ls.pop(0)
			status = os.waitpid(pid, 0)
			sys.stderr.write("%s return status: %s\n"%(pid, status))
			if len(inputfiles)>0:
				pid = self.init_match_on_that_machine(machine, inputdir, inputfiles, outputdir, match_bin_path, matrix_path, profile_filename)
				machine2child_pid_ls.append([machine, pid])
		sys.stderr.write("match done..\n")
	
	def init_repeat_masker_on_that_machine(self, machine, repeat_masker_bin_path, inputdir, inputfiles, repeat_masker_dir, organism):
		inputfilename = inputfiles.pop()
		inputfile = os.path.join(inputdir, inputfilename)
		job_ls = ['ssh', machine, repeat_masker_bin_path, '-species', organism, '-dir', repeat_masker_dir, inputfile]
		pid = os.spawnvp(os.P_NOWAIT,'ssh', job_ls)
		sys.stderr.write("%s (RM) dispatched\n"%inputfile)
		return pid
	
	def run_repeat_masker(self, machine_ls, inputdir, organism):
		sys.stderr.write("Running RepeatMasker...\n")
		repeat_masker_dir = os.path.abspath(inputdir)+'_masked'
		if not os.path.isdir(repeat_masker_dir):
			os.makedirs(repeat_masker_dir)
		repeat_masker_bin_path = '~/bin/RepeatMasker/RepeatMasker'
		machine2child_pid_ls = []
		inputfiles = os.listdir(inputdir)
		repeat_masker_output_files = []
		for inputfilename in inputfiles:
			repeat_masker_output_files.append(inputfilename+'.masked')
		
		for machine in machine_ls:
			if len(inputfiles)>0:	#check if there's more inputfile
				pid = self.init_repeat_masker_on_that_machine(machine, repeat_masker_bin_path, inputdir, inputfiles, repeat_masker_dir, organism)
				machine2child_pid_ls.append([machine, pid])
	
		#wait for each child to end and recycle
		while machine2child_pid_ls:
			machine,pid = machine2child_pid_ls.pop(0)
			status = os.waitpid(pid, 0)
			sys.stderr.write("%s return status: %s\n"%(pid, status))
			if len(inputfiles)>0:
				pid = self.init_repeat_masker_on_that_machine(machine, repeat_masker_bin_path, inputdir, inputfiles, repeat_masker_dir, organism)
				machine2child_pid_ls.append([machine, pid])		
		sys.stderr.write("RepeatMasker Done.\n")
		return repeat_masker_dir, repeat_masker_output_files
	
	def run(self):
		machine_ls = self.get_all_machines(self.machinefile)
		if self.type==1:
			inputfiles = os.listdir(self.inputdir)
		elif self.type == 2:
			self.inputdir, inputfiles = self.run_repeat_masker(machine_ls, self.inputdir, self.organism)
		self.run_match(machine_ls, inputfiles, self.inputdir, self.outputdir, self.profile_filename)
		

if __name__ == '__main__':
	if len(sys.argv)<5:
		print __doc__
		sys.exit(3)
	
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hm:i:o:p:g:y:", ["help", "type="])
	except:
		print __doc__
		sys.exit(2)
	
	machinefile = None
	inputdir = None
	outputdir = None
	profile_filename = None
	organism = 'human'
	type = 1
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-m",):
			machinefile = arg
		elif opt in ("-i",):
			inputdir = arg
		elif opt in ("-o",):
			outputdir = arg
		elif opt in ("-p",):
			profile_filename = arg
		elif opt in ("-g",):
			organism = arg
		elif opt in ("-y",):
			type = int(arg)
	
	if machinefile and inputdir and outputdir and profile_filename and type and organism:
		instance = batch_match(machinefile, inputdir, outputdir, profile_filename, organism, \
			type)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
