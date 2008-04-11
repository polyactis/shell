#!/usr/bin/env python
'''
Usage:	file_batch_move.py [OPTIONS] -i SRCDIR -o DSTDIR

Option:
	-i ...,	SRCDIR is the source directory.
	-o ...,	DSTDIR is the destiny directory.
	-l ..., --list_file=..., FILE contains the names of those files to be moved.
		if not given, all file/dirs in SRCDIR but NOT in DSTDIR.
		if 2nd-column (tab delimited) is available, it's regarded as the new filename.
	-t ..., --type=...,	type of move, 0(default), 1, 2, 3
	-h, --help              show this help
	
Examples:
	#print the file/dirs in ./Products/ but NOT in /usr/lib/zope2.9/lib/python/Products/
	file_batch_move.py -t3 -i ./Products/ -o /usr/lib/zope2.9/lib/python/Products/
	
Description:
	a program to move a bunch of files from one directory to another directory.
	It is useful for remote linux machines with no GUI access.
	It checks the DSTDIR to avoid name collision.
	TYPE of move:
	0:	test run. report all files to move.
	1:	symbolic link
	2:	os.rename(like mv, but can't cross-device)
	3:	os.link(like copy, but can't cross-device)
	4:	os.popen("mv src_pathname dst_pathname"). call UNIX 'mv' command.

'''

import sys, os, math
bit_number = math.log(sys.maxint)/math.log(2)
if bit_number>40:       #64bit
	sys.path.insert(0, os.path.expanduser('~/lib64/python'))
	sys.path.insert(0, os.path.join(os.path.expanduser('~/script64/annot/bin')))
else:   #32bit
	sys.path.insert(0, os.path.expanduser('~/lib/python'))
	sys.path.insert(0, os.path.join(os.path.expanduser('~/script/annot/bin')))
import getopt, csv, traceback
from sets import Set

class file_batch_move:
	def __init__(self, srcdir, dstdir, list_file, type):
		self.srcdir = os.path.abspath(srcdir)
		if not os.path.isdir(dstdir):
			os.makedirs(dstdir)
		self.dstdir = os.path.abspath(dstdir)
		self.list_file = list_file
		#the mapping between the type and the real action.
		move_dict = {0:self.print_fname,
					1:os.symlink,
			2:os.rename,
			3:os.link,
			4:self.call_mv}
		self.move = move_dict[int(type)]
	
	def call_mv(self, src_pathname, dst_pathname):
		"""
		2008-03-20
			
		"""
		pipe_f = os.popen('mv %s %s'%(src_pathname, dst_pathname))
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
	
	def get_diff_list_in_src_against_dst_dir(self, srcdir, dstdir):
		"""
		2008-04-11
			files_to_move becomes a dictionary. value=-1 because of no file renaming.
		2008-03-20
			get a set of file/dirs in srcdir, but NOT in dstdir
		"""
		sys.stderr.write("Getting a list of file/dirs in %s but NOT in %s ... "%( srcdir, dstdir))
		dst_obj_set = Set(os.listdir(dstdir))
		files_to_move = {}
		for obj in os.listdir(srcdir):
			if obj not in dst_obj_set:
				files_to_move[obj] = -1
		sys.stderr.write("Done.\n")
		return files_to_move
	
	def run(self):
		"""
		2008-04-11
			if list_file is two-column, 2nd column is treated as destination filename to be renamed to
		2008-03-20
			if -l is not given, it'll try to move all file/dir in SRCDIR but NOT in DSTDIR.
		"""
		if self.list_file:
			files_to_move = self.dstruc_loadin(self.list_file)
		else:
			files_to_move = self.get_diff_list_in_src_against_dst_dir(self.srcdir, self.dstdir)
		
		files = os.listdir(self.srcdir)
		no_of_files_to_move = len(files_to_move)
		sys.stderr.write("\tTotally, %d files to be moved from %s to %s.\n"%\
			(no_of_files_to_move, self.srcdir, self.dstdir))
		i=0
		for f in files:
			if f in files_to_move:
				i += 1
				sys.stderr.write("%d/%d:\t%s\n"%(i, no_of_files_to_move, f))
				src_pathname = os.path.join(self.srcdir, f)
				dst_fname = files_to_move[f]
				if dst_fname ==-1:	#same filename
					dst_pathname = os.path.join(self.dstdir, f)
				else:	#change filename
					dst_pathname = os.path.join(self.dstdir, dst_fname)
				try:
					self.move(src_pathname, dst_pathname)
				#symlink and link will fail if dst_pathname already exists.
				except OSError, error:
					sys.stderr.write('%s '%error)
					sys.stderr.write("IGNORE\n")

if __name__ == '__main__':
	if len(sys.argv) == 1:
		print __doc__
		sys.exit(2)
	
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hi:o:l:t:", ["help", "list_file=", "type="])
	except:
		traceback.print_exc()
		print sys.exc_info()
		sys.exit(2)
	
	srcdir = None
	dstdir = None
	list_file = ''
	type = 0
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
		elif opt in ("-t", "--type"):
			type = int(arg)
	
	if srcdir and dstdir:
		instance = file_batch_move(srcdir, dstdir, list_file, type)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
