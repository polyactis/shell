#!/usr/bin/env python
"""
Usage: count_columns.py [OPTION] FILES

Option:
	FILES are a list of files whose columns are going to be counted.
	-d ... --delimiter=...,	delimiter character used to seperate columns, \t(default)
	-n ...,	number of lines to read into the file and report the number of columns for each, 1(default)
	-h, --help              show this help
	
Examples:
	count_columns.py gph_result/sc/*
	count_columns.py -d ',' /tmp/dataset1

Description:
	report the number of columns of the first line of all files.
	FUTURE: consider a through check of the whole file.
"""
import sys, os, math
bit_number = math.log(sys.maxint)/math.log(2)
if bit_number>40:       #64bit
	sys.path.insert(0, os.path.expanduser('~/lib64/python'))
else:   #32bit
	sys.path.insert(0, os.path.expanduser('~/lib/python'))
import sys, os, re, getopt, csv

class count_columns:
	def __init__(self, file_list, delimiter, no_of_lines):
		"""
		2008-08-15
			add option no_of_lines. number of lines to read into the file and report the number of columns for each, 1(default)
		05-14-05
			dir is changed to file_list
		"""
		self.files = file_list
		self.files.sort()
		self.delimiter = delimiter
		self.no_of_lines = int(no_of_lines)

	def run(self):
		"""
		05-14-05
			f is directly the src_pathname
		"""
		sys.stderr.write("\tTotally, %d files to be processed.\n"%len(self.files))
		for f in self.files:
			sys.stdout.write("%d/%d:\t%s"%(self.files.index(f)+1,len(self.files),f))
			src_pathname = f
			reader = csv.reader(file(src_pathname), delimiter=self.delimiter)
			try:
				for i in range(self.no_of_lines):
					row = reader.next()
					sys.stdout.write("\tline %s: %d\n"%(i, len(row)))
			except:
				sys.stdout.write('csv reader.next error\n')
			del reader


if __name__ == '__main__':
	if len(sys.argv) == 1:
		print __doc__
		sys.exit(2)
		
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hd:n:", ["help", "delimiter="])
	except:
		print __doc__
		sys.exit(2)

	delimiter = '\t'
	no_of_lines = 1
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-d", "--delimiter"):
			delimiter = arg
		elif opt in ("-n",):
			no_of_lines = int(arg)

	if len(args)>=1:
		instance = count_columns(args, delimiter, no_of_lines)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
