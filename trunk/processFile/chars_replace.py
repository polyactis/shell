#!/usr/bin/env python
'''
Usage:	chars_replace.py [OPTIONS] SRCFILE DSTFILE

Option:
	SRCFILE is the source file.
	DSTFILE is the destiny file.
	-e ..., --replacee=...	specify the replacee
	-r ..., --replacer=...	specify the replacer
	-h, --help              show this help

Example:
	chars_replace.py -e '\\t\|\\t' -r '\\t' nodes.dmp nodes.dmp.new
	
Description:
	a program to replace characters in a file line by line.
'''

import sys, os, getopt, re

class chars_replace:
	def __init__(self, infname, ofname, replacee, replacer):
		self.infname = infname
		self.ofname = ofname
		self.replacee = re.compile(r'%s'%(replacee))
		self.replacer = replacer
	
	def dstruc_loadin(self):
		pass
		
	def run(self):
		self.dstruc_loadin()
		inf = open(self.infname, 'r')
		of = open(self.ofname, 'w')
		self.replace(inf, of)
		inf.close()
		of.close()

	def replace(self, inf, of):
		for line in inf:
			new_line = self.replacee.sub(self.replacer, line)
			of.write(new_line)
		
if __name__ == '__main__':
	if len(sys.argv) == 1:
		print __doc__
		sys.exit(2)
	try:
		opts, args = getopt.getopt(sys.argv[1:], "he:r:", ["help", "replacee=", "replacer="])
	except:
		print __doc__
		sys.exit(2)
	
	replacee = None
	replacer = None
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			print __doc__
			sys.exit(2)
		elif opt in ("-e", "--replacee"):
			replacee= arg
		elif opt in ("-r", "--replacer"):
			replacer = arg
	
	if len(args) == 2 and replacee and replacer:
		instance = chars_replace(args[0], args[1], replacee, replacer)
		instance.run()
	else:
		print __doc__
		sys.exit(2)
