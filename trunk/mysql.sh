#!/bin/sh
# 2010-4-25 a shortcut to connect to the stock_250k db
# Examples:
# 	Running without any argument will connect to localhost's stock_250k.
#	./mysql.sh
#
# 	Usual "$1 $2" argument would be "-h papaya".
#	./mysql.sh -h papaya
mysql -u yh -p $1 $2 --pager=less stock_250k
