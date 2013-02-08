while [ $? = "0" ]; do
	sleep 5m 
	date > tmp.dt
	ps -ef > tmp
	grep tree-puzzle tmp
		
done

halt
	
