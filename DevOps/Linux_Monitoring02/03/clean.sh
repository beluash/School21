#!/bin/bash

function clean_log {
    file="$(cat ../02/log.txt | awk '{print $1}')"
    for i in $file
    do
        sudo rm -rf $i
    done
    rm -rf ../02/log.txt
    echo "All folders and files were deleted"
}

function clean_date {
    echo "Enter the start time of the script YYYY-MM-DD HH:MM"
    read s_date
    echo "Enter the end time of the script YYYY-MM-DD HH:MM"
    read e_date e_time
    #rm -rf $(sudo find / -not -path '/proc/*' -newermt "$s_date" -not -newermt "$e_date $( date +%H:%M -s $e_time-00:01 )" | grep $date | sort)
    rm -rf $( find / | grep "_$date")
    rm -rf ../02/log.txt
    echo "All folders and files were deleted"
}

function clean_mask {
    rm -rf /*/*$date.*
    rm -rf ../02/log.txt
    echo "All folders and files were deleted"
}