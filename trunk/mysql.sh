#!/bin/sh
# 2010-4-25 a shortcut to connect to the stock_250k db
# Examples:
# 	Running without any argument will connect to localhost's stock_250k.
#	./mysql.sh
#
# 	All arguments will be passed to mysql. Usual argument would be "-h papaya".
#	./mysql.sh -h papaya
mysql -u yh -p $* --pager=less stock_250k
