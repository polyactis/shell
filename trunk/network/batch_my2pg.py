#!/usr/bin/env python
'''
This is batch program to convert mysql dumps to postgresql dumps.

Usage:	'program_name' arg1
	
	arg1 is the name of the directory containing mysql dumped files
		the extension of all the files is 'sql'.
	The converted pgsql dumps will be outputted to stdout.
'''

import os,sys,psycopg,getopt

def batch(dataset_dir):
	files = os.listdir(dataset_dir)
	sys.stderr.write("\tTotally, %d files to be processed.\n"%len(files))
	homedir = os.path.expanduser('~')
	
	for f in files:
		sys.stderr.write("%d/%d:\t%s\n"%(files.index(f)+1,len(files),f))
		prefix,ext = os.path.splitext(f)
		if ext == '.sql':
			src_file = os.path.join(dataset_dir, f)
			wl = ['my2pg.pl', '-n', src_file]
			os.spawnvp(os.P_WAIT, '/usr/lib/postgresql/bin/my2pg.pl', wl)
			sys.stderr.write('\tconverted\n')

if __name__ == '__main__':
	if len(sys.argv) == 2:
		batch(sys.argv[1])
	else:
		print __doc__
		sys.exit(2)
