#!/usr/bin/env python
'''
Usage:	file_batch_move.py -l FILE SRCDIR DSTDIR

Option:
	SRCDIR is the source directory.
	DSTDIR is the destiny directory.
	-l ..., --list_file=..., FILE contains the names of those files to be moved.
	-h, --help              show this help
	
Description:
	a program to move a bunch of files from one directory to another directory.
	It is useful for remote linux machines with no GUI access.
'''

import sys, os, getopt, csv
from sets import Set

class file_batch_move:
	def __init__(self, srcdir, dstdir, list_file):
		self.srcdir = srcdir
		self.dstdir = dstdir
		self.list_f = csv.reader(file(list_file))
		self.files_to_move = Set()
	
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
				os.rename(src_pathname, dst_pathname)

if __name__ == '__main__':
	if len(sys.argv) == 1:
		print __doc__
		sys.exit(2)
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hl:", ["help", "list_file="])
	except:
		print __doc__
		sys.exit(2)
	
	list_file = ''
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-l", "--list_file"):
			list_file = arg
	
	if list_file and len(args) == 2:
		instance = file_batch_move(args[0], args[1], list_file)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
