#!/bin/sh
while sleep 1;do
	tput sc;tput cup 0 $(($(tput cols)-28));date;tput rc;
done
