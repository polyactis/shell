#!/usr/bin/env python
"""
Usage: file_rename.py -m MAPPING_FILE -s CHOICE [OPTION] DIR

Option:
	DIR is the directory which contains the files to be renamed.
	-p ..., --prefix=...	prefix needed for choice 4 renaming
	-s ..., --choice=...	which type of renaming rule.
	-m ..., --mapping_file==...	1st column is the old fname, 2nd is the new fname
	-h, --help              show this help
	
Examples:
	file_rename.py -s 1 -m /tmp/mapping gph_result/sc		Restore filenames
	file_rename.py -s 2 -m /tmp/mapping gph_result/hs
	file_rename.py -s 3 -m /tmp/mapping -p hs_gph_dataset gph_result/hs
	file_rename.py -s 4 -p mm_dataset -m mapping/mm_47_dataset_mapping mm_47/

Description:
	Choices:
	1: restore. Change the filenames according to mapping file. 2nd-column new filename -> 1st-column old.
	2: prefix_ext_swap
	3: lower_case
	4: datasets_sort
	When choice is 4, you must specify the prefix.
"""

import sys, os, math
bit_number = math.log(sys.maxint)/math.log(2)
if bit_number>40:       #64bit
	sys.path.insert(0, os.path.expanduser('~/lib64/python'))
	sys.path.insert(0, os.path.join(os.path.expanduser('~/script64/annot/bin')))
else:   #32bit
	sys.path.insert(0, os.path.expanduser('~/lib/python'))
	sys.path.insert(0, os.path.join(os.path.expanduser('~/script/annot/bin')))
import re, getopt, csv

class rename:
	def __init__(self, dir, prefix, choice, mapping_file):
		self.dir = dir
		self.files = os.listdir(dir)
		self.files.sort()
		self.prefix = prefix
		self.choice = int(choice)
		if self.choice == 1:
			self.m_file = csv.reader(file(mapping_file), delimiter='\t')
		else:
			self.m_file = open(mapping_file, 'w')
		function_dict = {
			1:self.restore,
			2:self.prefix_ext_swap,
			3:self.lower_case,
			4:self.datasets_sort
			}
		if self.choice not in function_dict:
			sys.stderr.write("%d: unavailable choice\n"%self.choice)
			sys.exit(2)
		self.rule = function_dict[self.choice]
		#data structure which maps the new filename to old filename,
		#used to restore the filenames
		self.new2old_dict = {}
		
	def dstruc_loadin(self):
		for row in self.m_file:
			'''
			the mapping_file is created by this program itself.
			The 1st column is old filename, 2nd column is the new filename.
			'''
			self.new2old_dict[row[1]] = row[0]

	def run(self):
		sys.stderr.write("\tTotally, %d files to be processed.\n"%len(self.files))
		if self.choice == 1:
			self.rule()
		else:
			for f in self.files:
				sys.stderr.write("%d/%d:\t%s\n"%(self.files.index(f)+1,len(self.files),f))
				src_pathname = os.path.join(self.dir, f)
				new_fname = self.rule(f)
				dst_pathname = os.path.join(self.dir, new_fname)
				os.rename(src_pathname, dst_pathname)
				self.m_file.write('%s\t%s\n'%(f, new_fname))
		del self.m_file	#05-13-05 sometimes it's csv.reader. sometimes, it's an open file handler.
			#delete it to close the open file handler.
		
	def restore(self):
		#loadin the new2old_dict.
		self.dstruc_loadin()
		
		for f in self.files:
			if f in self.new2old_dict:
				sys.stderr.write("%d/%d:\t%s\n"%(self.files.index(f)+1,len(self.files),f))
				src_pathname = os.path.join(self.dir, f)
				dst_pathname = os.path.join(self.dir, self.new2old_dict[f])
				os.rename(src_pathname, dst_pathname)

	
	def datasets_sort(self, f):
		if self.prefix == '':
			sys.stderr.write('You must specify the prefix.\n')
			sys.exit(2)
		new_fname = '%s%d'%(self.prefix, self.files.index(f)+1)
		return new_fname
	
	def prefix_ext_swap(self, f):
		prefix,ext = os.path.splitext(f)
		if ext == ext[1:]:
			sys.stderr.write('the filename has no extension, ignore\n')
			return f
		#remove the dot(.)
		ext = ext[1:]
		new_fname = ext+'_'+prefix
		return new_fname

	def lower_case(self, f):
		new_fname = f.lower()
		return new_fname

if __name__ == '__main__':
	if len(sys.argv) == 1:
		print __doc__
		sys.exit(2)
		
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hp:s:m:", ["help", "prefix=", "choice=", "mapping_file="])
	except:
		print __doc__
		sys.exit(2)
	
	prefix = ''
	choice = None
	mapping_file = None
	
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-p", "--prefix"):
			prefix = arg
		elif opt in ("-s", "--choice"):
			#choice will be integered in the class.
			choice = arg
		elif opt in ("-m", "--mapping_file"):
			mapping_file = arg
			
	if choice and mapping_file and len(args)==1:
		instance = rename(args[0], prefix, choice, mapping_file)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
