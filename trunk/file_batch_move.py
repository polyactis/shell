#!/usr/bin/env python
'''
Examples:
	#print the file/dirs in ./Products/ but NOT in /usr/lib/zope2.9/lib/python/Products/
	%s -t3 -i ./Products/ -o /usr/lib/zope2.9/lib/python/Products/
	
	#2011-8-31 find all files that needs to be moved.
	%s -i /Network/Data/vervet/db/individual_sequence/
		-o /mnt/hoffman2/u/home/eeskintmp/polyacti/NetworkData/vervet/db/individual_sequence/
	
	#2011-8-31 compare files between two directories and copy to a 3rd directory (/mnt/sdd2)
	%s -i /Network/Data/vervet/db/individual_sequence/
		-o /mnt/hoffman2/u/home/eeskintmp/polyacti/NetworkData/vervet/db/individual_sequence/ -d /mnt/sdd2/ -t 5
	
Description:
	a program to move a bunch of files from one directory to another directory, recursively.
		It is useful for remote linux machines with no GUI access.
	It checks the DSTDIR. only files that don't exist in DSTDIR or whose size is smaller than those in SRCDIR.
	move_type of move:
	0:	test run. report all files to move.
	1:	symbolic link
	2:	os.rename(like mv, but can't cross-device)
	3:	os.link(like copy, but can't cross-device)
	4:	os.popen("mv src_pathname dst_pathname"). call UNIX 'mv' command.
	5:	os.popen("cp src_pathname dst_pathname"). call UNIX 'cp' command.
	If argument dstdir2 is given, comparison is still between SRCDIR and DSTDIR but data is copied from SRCDIR to dstdir2.
'''

import sys, os, math
__doc__ = __doc__%(sys.argv[0], sys.argv[0], sys.argv[0])
bit_number = math.log(sys.maxint)/math.log(2)
if bit_number>40:       #64bit
	sys.path.insert(0, os.path.expanduser('~/lib64/python'))
	sys.path.insert(0, os.path.join(os.path.expanduser('~/script64/')))
else:   #32bit
	sys.path.insert(0, os.path.expanduser('~/lib/python'))
	sys.path.insert(0, os.path.join(os.path.expanduser('~/script/')))
import getopt, csv, traceback, re

class file_batch_move:
	__doc__ = __doc__
	option_default_dict = {
						('srcdir', 1,):['', 'i', 1, 'SRCDIR is the source directory', ],\
						('dstdir', 1, ): ['', 'o', 1, '	DSTDIR is the destiny directory.', ],\
						('dstdir2', 0, ): ['', 'd', 1, '	DSTDIR2, if given, is where the files would go to. Hierarchical directories would be created.', ],\
						('list_file', 0, ): ['', 'm', 1, 'FILE contains the names of those files to be moved.\
		if not given, all file/dirs in SRCDIR but NOT in DSTDIR.\
		if 2nd-column (tab delimited) is available, it is regarded as the new filename.', ],\
						('move_type', 1, int): [0, 't', 1, 'type of move, 0(default), 1, 2, 3', ],\
						('sync_type', 1, int): [0, 's', 1, 'type of sync, 0(size + existence), 1 (existence)', ],\
						('debug', 0, int): [0, 'b', 0, 'toggle debug mode'],\
						('report', 0, int): [0, 'r', 0, 'toggle report, more verbose stdout/stderr.']}
	
	def __init__(self, **keywords):
		from pymodule import ProcessOptions
		self.ad = ProcessOptions.process_function_arguments(keywords, self.option_default_dict, error_doc=self.__doc__, \
														class_to_have_attr=self)
		
		self.srcdir = os.path.abspath(self.srcdir)
		if not os.path.isdir(self.dstdir):
			os.makedirs(self.dstdir)
		self.dstdir = os.path.abspath(self.dstdir)
		#the mapping between the move_type and the real action.
		move_dict = {0:self.print_fname,
					1:os.symlink,
			2:os.rename,
			3:os.link,
			4:self.call_mv,
			5:self.call_cp}
		self.move = move_dict[int(self.move_type)]
	
	def call_mv(self, src_pathname, dst_pathname):
		"""
		2008-03-20
			
		"""
		pipe_f = os.popen('mv %s %s'%(src_pathname, dst_pathname))
		pipe_f_out = pipe_f.read()
		if pipe_f_out:
			sys.stderr.write("\tmv output: %s\n"%pipe_f_out)
	
	def call_cp(self, src_pathname, dst_pathname):
		"""
		2008-08-19
			real copy, could cross device compared to os.link
		"""
		pipe_f = os.popen('cp "%s" "%s"'%(src_pathname, dst_pathname))
		pipe_f_out = pipe_f.read()
		if pipe_f_out:
			sys.stderr.write("\tmv output: %s\n"%pipe_f_out)
	
	def print_fname(self, src_pathname, dst_pathname):
		"""
		2008-03-20
			to have same interface as other objects in move_dict
		"""
		print src_pathname
	
	def dstruc_loadin(self, list_file):
		"""
		2008-04-11
			if list_file is two-column, 2nd column is treated as destination filename to be renamed to
		2008-03-20
			restructure it to make it more independent
		"""
		sys.stderr.write("Reading a list of file/dirs from %s ... "%list_file)
		list_f = csv.reader(file(list_file), delimiter='\t')
		#stores the files to move
		files_to_move = {}
		for row in list_f:
			if len(row)==2:
				files_to_move[row[0]] = row[1]
			else:
				files_to_move[row[0]] = -1
		sys.stderr.write("Done.\n")
		return files_to_move
	
	def getAllFiles(self, inputDir, inputFiles=[]):
		"""
		2011-8-3
			recursively going through the directory to get all bam files
			
		"""
		
		for inputFname in os.listdir(inputDir):
			#get the absolute path
			inputFname = os.path.join(inputDir, inputFname)
			if os.path.isfile(inputFname):
				inputFiles.append(inputFname)
			elif os.path.isdir(inputFname):
				self.getAllFiles(inputFname, inputFiles)
	
	def get_diff_list_in_src_against_dst_dir(self, srcdir, dstdir, pattern_without_srcdir=None):
		"""
		2011-8-31
			add pattern_without_srcdir
		2008-04-11
			files_to_move becomes a dictionary. value=-1 because of no file renaming.
		2008-03-20
			get a set of file/dirs in srcdir, but NOT in dstdir
		"""
		sys.stderr.write("Getting a list of file/dirs in %s but NOT in %s ... "%( srcdir, dstdir))
		#dst_obj_set = Set(os.listdir(dstdir))
		files_to_move = {}
		inputFiles = []
		self.getAllFiles(srcdir, inputFiles)
		for src_abs_path in inputFiles:
			relative_path = pattern_without_srcdir.search(src_abs_path).group(1)
			dst_abs_path = os.path.join(dstdir, relative_path)
			if os.path.exists(dst_abs_path):
				src_file_size = os.path.getsize(src_abs_path)
				dst_file_size = os.path.getsize(dst_abs_path)
				if self.sync_type==0 and dst_file_size<src_file_size:	#2011-8-31 smaller, need to copy as well.
					files_to_move[src_abs_path] = -1
			else:
				#if src_abs_path not in dst_obj_set:
				files_to_move[src_abs_path] = -1
		sys.stderr.write("%s files. Done.\n"%(len(files_to_move)))
		return files_to_move
	
	def run(self):
		"""
		2008-04-11
			if list_file is two-column, 2nd column is treated as destination filename to be renamed to
		2008-03-20
			if -l is not given, it'll try to move all file/dir in SRCDIR but NOT in DSTDIR.
		"""
		if self.debug:
			import pdb
			pdb.set_trace()
		#2011-8-31
		pattern_without_srcdir = re.compile(r'%s/+(.*)'%self.srcdir)	#to get anything but the srcdir and remove all the "/"
			#the beginning "/" in relative_path would prevent it from joining with the dstdir in os.path.join
		if self.list_file:
			files_to_move = self.dstruc_loadin(self.list_file)
		else:
			files_to_move = self.get_diff_list_in_src_against_dst_dir(self.srcdir, self.dstdir, \
																	pattern_without_srcdir=pattern_without_srcdir)
		
		#files = os.listdir(self.srcdir)
		no_of_files_to_move = len(files_to_move)
		sys.stderr.write("\tTotally, %d files to be moved from %s to %s.\n"%\
			(no_of_files_to_move, self.srcdir, self.dstdir))
		i=0
		for f in files_to_move:
			i += 1
			sys.stderr.write("%d/%d:\t%s\n"%(i, no_of_files_to_move, f))
			if not os.path.isabs(f):
				src_pathname = os.path.join(self.srcdir, f)
			else:
				src_pathname = f
			dst_fname = files_to_move[f]
			if dst_fname ==-1:	#same filename
				relative_path = pattern_without_srcdir.search(src_pathname).group(1)
				if self.dstdir2:
					dst_pathname = os.path.join(self.dstdir2, relative_path)
				else:
					dst_pathname = os.path.join(self.dstdir, relative_path)
				dst_dir_hier = os.path.split(dst_pathname)[0]
				if self.move_type!=0 and not os.path.exists(dst_dir_hier):	#2011-8-31 create directory hiearchy if non-existent
					os.makedirs(dst_dir_hier)
			else:	#change filename
				dst_pathname = os.path.join(self.dstdir, dst_fname)

			try:
				self.move(src_pathname, dst_pathname)
			#symlink and link will fail if dst_pathname already exists.
			except OSError, error:
				sys.stderr.write('%s '%error)
				sys.stderr.write("IGNORE\n")

if __name__ == '__main__':
	from pymodule import ProcessOptions
	main_class = file_batch_move
	po = ProcessOptions(sys.argv, main_class.option_default_dict, error_doc=main_class.__doc__)
	instance = main_class(**po.long_option2value)
	instance.run()
	"""
	if len(sys.argv) == 1:
		print __doc__
		sys.exit(2)
	
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hi:o:l:t:", ["help", "list_file=", "move_type="])
	except:
		traceback.print_exc()
		print sys.exc_info()
		sys.exit(2)
	
	srcdir = None
	dstdir = None
	list_file = ''
	move_type = 0
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-i",):
			srcdir = arg
		elif opt in ("-o",):
			dstdir = arg
		elif opt in ("-l", "--list_file"):
			list_file = arg
		elif opt in ("-t", "--move_type"):
			move_type = int(arg)
	
	if srcdir and dstdir:
		instance = file_batch_move(srcdir, dstdir, list_file, move_type)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
	"""
