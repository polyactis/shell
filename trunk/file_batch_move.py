#!/usr/bin/env python
'''
Usage:	file_batch_move.py SRCDIR DSTDIR

Description:
	a program to move a bunch of files from one directory to another directory.
	It is useful for remote linux machines with no GUI access.
'''

import sys,os,re
from sets import Set

class file_batch_move:
	def __init__(self, srcdir, dstdir):
		self.srcdir = srcdir
		self.dstdir = dstdir
		self.files_to_move = Set(['01-20-04.job'])
		self.no_of_files_to_move = len(self.files_to_move)
	
	def run(self):
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
	if len(sys.argv) != 3:
		print __doc__
		sys.exit(2)
	
	instance = file_batch_move(sys.argv[1], sys.argv[2])
	instance.run()
