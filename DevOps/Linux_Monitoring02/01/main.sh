#!/bin/bash

log_file="log.txt"
sudo touch $log_file

folder_name=$3
date="$(date +"%d%m%y")"
log_date="$(date +"%d.%m.%y")"
last_letter_folder=${folder_name: -1}
file_name=$(echo $5 | awk -F. '{print $1}')
file_ext=$(echo $5 | awk -F. '{print $2}')
last_letter_file=${file_name: -1}

. input_check.sh
. creating_objects.sh