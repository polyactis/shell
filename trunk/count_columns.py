#!/usr/bin/env python
"""
Usage: count_columns.py [OPTION] FILES

Option:
	FILES are a list of files whose columns are going to be counted.
	-d ... --delimiter=...,	delimiter character used to seperate columns, \t(default)
	-h, --help              show this help
	
Examples:
	count_columns.py gph_result/sc/*
	count_columns.py -d ',' /tmp/dataset1

Description:
	report the number of columns of the first line of all files.
	FUTURE: consider a through check of the whole file.
"""

import sys, os, re, getopt, csv

class count_columns:
	def __init__(self, file_list, delimiter):
		"""
		05-14-05
			dir is changed to file_list
		"""
		self.files = file_list
		self.files.sort()
		self.delimiter = delimiter

	def run(self):
		"""
		05-14-05
			f is directly the src_pathname
		"""
		sys.stderr.write("\tTotally, %d files to be processed.\n"%len(self.files))
		for f in self.files:
			sys.stderr.write("%d/%d:\t%s"%(self.files.index(f)+1,len(self.files),f))
			src_pathname = f
			reader = csv.reader(file(src_pathname), delimiter=self.delimiter)
			try:
				row = reader.next()
				sys.stderr.write("\t%d\n"%len(row))
			except:
				sys.stderr.write('csv reader.next error\n')
			del reader


if __name__ == '__main__':
	if len(sys.argv) == 1:
		print __doc__
		sys.exit(2)
		
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hd:", ["help", "delimiter="])
	except:
		print __doc__
		sys.exit(2)

	delimiter = '\t'
	
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-d", "--delimiter"):
			delimiter = arg

	if len(args)>=1:
		instance = count_columns(args, delimiter)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
