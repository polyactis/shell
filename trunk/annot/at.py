#!/usr/bin/python

import psycopg

conn = psycopg.connect("dbname=mdb user=yh")
curs = conn.cursor()

curs.execute("set search_path to geo,smd")
curs.execute("select distinct dataset_id,gsmid,description into sample_tmp from data")
#curs.execute("select distinct dataset_id,gsmid,description into sample_mm from data_mm")
#print "hs & mm sample_id selected out"
#curs.execute("create index exptid_suid_hs_idx on result_hs(exptid,suid)")
#curs.execute("create index gsmid_idx on data(gsmid)")
#curs.execute("create index gsmid_at_idx on data_at(gsmid)")
#curs.execute("create index gsmid_dm_idx on data_dm(gsmid)")
#curs.execute("create index gsmid_mm_idx on data_mm(gsmid)")
#curs.execute("create index gsmid_sc_idx on data_sc(gsmid)")
print 'sample information extracted'
#curs.execute("select distinct suid,clusterid,accession into three_col_hs from result")

conn.commit()
