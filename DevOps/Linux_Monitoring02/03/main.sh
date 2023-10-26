#!/bin/bash

date="$(cat ../02/log.txt | awk '{print $1}' | awk -F'_' '{print $2}')"

. input_check.sh
. clean.sh

if [[ $1 -eq "1" ]]
then
    clean_log
elif [[ $1 -eq "2" ]]
then
    clean_date
else
    clean_mask
fi

