#!/bin/bash

#*******************************
# Multiple dropbox instances
#*******************************

dropboxes=". .dropbox-alt"

for dropbox in $dropboxes
do
    HOME=/home/$USER
    if ! [ -d $HOME/$dropbox ];then
        mkdir $HOME/$dropbox 2> /dev/null
        ln -s $HOME/.Xauthority $HOME/$dropbox/ 2> /dev/null
    fi
    echo $dropbox
    HOME=$HOME/$dropbox /usr/bin/dropbox start -i 2> /dev/null &
    sleep 10
done 
