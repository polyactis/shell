#!/usr/bin/python

import psycopg

conn = psycopg.connect("dbname=mdb user=yh")
curs = conn.cursor()

curs.execute("set search_path to geo,smd")
#curs.execute("select distinct dataset_id,gsmid,description into sample_hs from data_hs")
#curs.execute("select distinct dataset_id,gsmid,description into sample_mm from data_mm")
#print "hs & mm sample_id selected out"
#curs.execute("create index exptid_suid_hs_idx on result_hs(exptid,suid)")
curs.execute("create index exptid_at_idx on result_at(exptid)")
curs.execute("create index exptid_ce_idx on result_ce(exptid)")
curs.execute("create index exptid_dm_idx on result_dm(exptid)")
curs.execute("create index exptid_hs_idx on result_hs(exptid)")
curs.execute("create index exptid_mm_idx on result_mm(exptid)")
curs.execute("create index exptid_sc_idx on result_sc(exptid)")
#curs.execute("copy result_hs from '/mnt/hda1/tmp/result_hs'")
conn.commit()
print "6 indices of SMD done"
#curs.execute("select distinct suid,clusterid,accession into three_col_hs from result")

