#!/bin/bash

function sort_answer {
    for (( i=1; i <= 5; i++ ))
    do
        sort -k 9 ../04/$i.log -o sort$i.log
        cat sort$i.log
    done
}

function unique_ip {
    for (( i = 1; i <= 5; i++ ))
    do
        awk '{print $1}' ../04/$i.log | uniq -u > sort$i.log
        cat sort$i.log
    done
}

function error_requests {
    for (( i = 1; i <= 5; i++ ))
    do
        awk '$9 ~ /[45]/' ../04/$i.log > sort$i.log
        cat sort$i.log
    done
}

function error_unique_ip {
    for (( i = 1; i <= 5; i++ ))
    do
        awk '$9 ~ /[45]/' ../04/$i.log | awk '{print $1}' | uniq -u > sort$i.log
        cat sort$i.log
    done
}