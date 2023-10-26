#!/bin/bash

for (( i=${#folder_name}; i<4; i++ ))
do
    folder_name+="$(echo $last_letter_folder)"
done

for (( i=${#file_name}; i<4; i++ ))
do
    file_name+="$(echo $last_letter_file)"
done

olf_file_name=$file_name

for (( i=1; i<$2; i++))
do
    sudo mkdir -p "$1/"$folder_name"_"$date""
    echo "$1/"$folder_name"_"$date" created on "$log_date"" | sudo tee -a $log_file
    for (( j=1; j<$4; j++))
    do
        if [[ $(df / -BM | grep "/" | awk -F"M" '{ print $3 }') -gt 1024 ]]
        then
        sudo fallocate -l $6 ""$1"/"$folder_name"_"$date"/"$file_name"_"$date"."$file_ext""
        log_line="$1/"$folder_name"/"$file_name"_"$date" created on "$log_date", size: "$6""
        echo $log_line | sudo tee -a $log_file
        file_name+="$(echo $last_letter_file)"
        else
            echo "No more space available"
            exit 1
        fi
    done
    file_name=$olf_file_name
    folder_name+="$(echo $last_letter_folder)"
done