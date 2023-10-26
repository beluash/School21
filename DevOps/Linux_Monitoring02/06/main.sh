#!/bin/bash

if [[ $1 == "1" ]]
then
    sudo apt install goaccess
    sudo cp goaccess.conf /etc/goaccess/goaccess.conf
fi

for (( i=1; i <= 5; i++ ))
do
    sudo goaccess ../04/$i.log --log-format=COMBINED -a -o ../06/index_$i.html
done