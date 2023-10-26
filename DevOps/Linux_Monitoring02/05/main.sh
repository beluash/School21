#!/bin/bash

. ./input_check.sh
. ./analyzer.sh

if [[ $1 == 1 ]]
then
    sort_answer
elif [[ $1 == 2 ]]
then
    unique_ip
elif [[ $1 == 3 ]]
then
    error_requests
else
    error_unique_ip
fi