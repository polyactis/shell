while [ $? = "0" ]; do
	sleep 5m 
	date > tmp.dt
	ps -ef > tmp
	grep 'make xml -j10 -k' tmp
		
done

halt
	
