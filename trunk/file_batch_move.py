#!/usr/bin/env python
'''
Usage:	file_batch_move.py -l FILE SRCDIR DSTDIR

Option:
	SRCDIR is the source directory.
	DSTDIR is the destiny directory.
	-l ..., --list_file=..., FILE contains the names of those files to be moved.
	-t ..., --type=...,	type of move, 0(default), 1, or 2
	-h, --help              show this help
	
Description:
	a program to move a bunch of files from one directory to another directory.
	It is useful for remote linux machines with no GUI access.
	TYPE of move:
	0:	symbolic link
	1:	real move(mv)
	2:	copy
'''

import sys, os, math
bit_number = math.log(sys.maxint)/math.log(2)
if bit_number>40:       #64bit
	sys.path.insert(0, os.path.expanduser('~/lib64/python'))
	sys.path.insert(0, os.path.join(os.path.expanduser('~/script64/annot/bin')))
else:   #32bit
	sys.path.insert(0, os.path.expanduser('~/lib/python'))
	sys.path.insert(0, os.path.join(os.path.expanduser('~/script/annot/bin')))
import getopt, csv
from sets import Set

class file_batch_move:
	def __init__(self, srcdir, dstdir, list_file, type):
		self.srcdir = os.path.abspath(srcdir)
		if not os.path.isdir(dstdir):
			os.makedirs(dstdir)
		self.dstdir = os.path.abspath(dstdir)
		self.list_f = csv.reader(file(list_file))
		#stores the files to move
		self.files_to_move = Set()
		#the mapping between the type and the real action.
		move_dict = {0:os.symlink,
			1:os.rename,
			2:os.link}
		self.move = move_dict[int(type)]
	
	def dstruc_loadin(self):
		for row in self.list_f:
			self.files_to_move.add(row[0])
		self.no_of_files_to_move = len(self.files_to_move)
		
	def run(self):
		self.dstruc_loadin()
		
		files = os.listdir(self.srcdir)
		sys.stderr.write("\tTotally, %d files to be moved from %s to %s.\n"%\
			(self.no_of_files_to_move, self.srcdir, self.dstdir))
		i=0
		for f in files:
			if f in self.files_to_move:
				i += 1
				sys.stderr.write("%d/%d:\t%s\n"%(i, self.no_of_files_to_move, f))
				src_pathname = os.path.join(self.srcdir, f)
				dst_pathname = os.path.join(self.dstdir, f)
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
		opts, args = getopt.getopt(sys.argv[1:], "hl:t:", ["help", "list_file=", "type="])
	except:
		print __doc__
		sys.exit(2)
	
	list_file = ''
	type = 0
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-l", "--list_file"):
			list_file = arg
		elif opt in ("-t", "--type"):
			type = int(arg)
	
	if list_file and len(args) == 2:
		instance = file_batch_move(args[0], args[1], list_file, type)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
