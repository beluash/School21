#!/bin/bash

if [[ $# == 0 ]]
then
    . ./creating_logs.sh
    creating_info_files
    logs
    clean
else
    echo "Should not have arguments"
    exit 1
fi