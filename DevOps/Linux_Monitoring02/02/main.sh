#!/bin/bash

start_time_sec=$(date +%s.%N)
start_time=$(date +'%Y-%m-%d %H:%M')

log_file="log.txt"
sudo touch $log_file

system_folder_name=$(compgen -d / | shuf -n1)
folder_name=$1
date="$(date +"%d%m%y")"
log_date="$(date +"%d.%m.%y")"
last_letter_folder=${folder_name: -1}
file_name=$(echo $2 | awk -F. '{print $1}')
file_ext=$(echo $2 | awk -F. '{print $2}')
last_letter_file=${file_name: -1}

. input_check.sh
(. ./creating_objects.sh)

echo "Start time: "$start_time"" | sudo tee -a $log_file
echo "End time:" "$(date +'%Y-%m-%d %H:%M')" | sudo tee -a $log_file
diff=$(echo "$(date +%s.%N) - $start_time_sec" | bc)
printf "Execution time: %.6f seconds\n" $diff | sudo tee -a $log_file