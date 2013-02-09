#!/usr/bin/env python
'''
Usage:	column_format.py [OPTIONS] SRCFILE DSTFILE

Option:
	SRCFILE is the source file.
	DSTFILE is the destiny file.
	-d ..., --delimit=...	specify the delimiter, '\t' is default
	-n ..., --column_number=..., which column, 0(default)
	-t ..., --type=...,	type of format, 0(default)
	-h, --help              show this help

Example:
	column_format.py -n 1 ~/unigene_linking/suid_orf_sc ~/unigene_linking/suid_orf_sc_cap

Description:
	a program to format a specified column in a file.
	TYPE of format:
	0:	capitalize
'''

import sys, os, getopt, csv
from sets import Set

class column_format:
	def __init__(self, infname, ofname, delimit, column_number, type):
		self.infname = infname
		self.ofname = ofname
		self.delimit = delimit
		self.column_number = int(column_number)
		format_dict = {0: self.capitalize}
		self.format = format_dict[int(type)]
	
	def dstruc_loadin(self):
		pass
		
	def run(self):
		self.dstruc_loadin()
		inf = open(self.infname, 'r')
		of = open(self.ofname, 'w')
		self.format(inf, of)
		inf.close()
		of.close()

	def capitalize(self, inf, of):
		in_reader = csv.reader(inf, delimiter=self.delimit)
		out_writer = csv.writer(of, delimiter = self.delimit)
		for row in in_reader:
				
				row[self.column_number] = row[self.column_number].upper()
				out_writer.writerow(row)
		del in_reader, out_writer
		
if __name__ == '__main__':
	if len(sys.argv) == 1:
		print __doc__
		sys.exit(2)
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hd:n:t:", ["help", "delimit=", "column_number=", "type="])
	except:
		print __doc__
		sys.exit(2)
	
	delimit = '\t'
	column_number = 0
	type = 0
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-d", "--delimit"):
			delimit = arg
		elif opt in ("-n", "--column_number"):
			column_number = arg
		elif opt in ("-t", "--type"):
			type = int(arg)
	
	if len(args) == 2:
		instance = column_format(args[0], args[1], delimit, column_number, type)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
