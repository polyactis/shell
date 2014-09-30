#!/bin/bash
# SCRIPT: digclock.sh
# USAGE:  ./digiclock &
# PURPOSE: Displays time and date in the top right corner of the
#          screen using ANSI escape sequences.
# To stop this digclock use command kill pid.
################################################################

#################### VARIABLE DECLARATION ######################

 # To place the clock on the appropriate column, subtract the
 # length of $Time and $Date, which is 22, from the total number
 # of columns

  Columns=$(tput cols)
  Startpoint=$(($Columns-22))

 # If you're in an X Window System terminal,you can resize the
 # window, and the clock will adjust its position because it is
 # displayed at the last column minus 22 characters.

########################### MAIN PROGRAM #######################

# The script is executed inside a while without conditions.

while :
do
  Time=`date +%r`
  Date=`date +"%d-%m-%Y"`
  echo -en "\033[s"    #save current screen position & attributes

  tput cup 0 $Startpoint

 # You can also use bellow one liner.
 # tput cup 0 $((`tput cols`-22))
 # But it is not efficient to calculate cursor position for each
 # iteration. That's why I placed variable assignment before
 # beginning of the loop

 # print time and date in the top right corner of the screen

  echo -en "\033[42m$Time \033[46m$Date\033[0m"

 #restore current screen position & attributes

  echo -e -n "\033[u"

 #Delay for 1 second

  sleep 1
done
