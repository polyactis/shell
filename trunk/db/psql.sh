#!/bin/sh
# 2011-4-27 a shortcut to connect to the vervetdb
# Examples:
# 	Running without any argument will connect to localhost's vervetdb.
#	psql.sh
#
# 	All arguments will be passed to mysql. Usual argument would be "-h papaya".
#	psql.sh -h papaya
#mysql -u yh -p $* --pager=less stock_250k
psql -h localhost -U yh -W vervetdb $*
