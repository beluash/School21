#!/bin/bash

for (( i=${#folder_name}; i<5; i++ ))
do
    folder_name+="$(echo $last_letter_folder)"
done

for (( i=${#file_name}; i<5; i++ ))
do
    file_name+="$(echo $last_letter_file)"
done

for (( i=1; i<100; i++ ))
do
    while [[ $system_folder_name == "/bin" || $system_folder_name == "/sbin" || $system_folder_name == "/root" ||  $system_folder_name == "/proc" || $system_folder_name == "/sys" || $system_folder_name == "/boot" ]]
    do 
        system_folder_name=$(compgen -d / | shuf -n1)
    done
    olf_file_name=$file_name
    sudo mkdir -p ""$system_folder_name"/"$folder_name"_"$date""
    echo ""$system_folder_name"/"$folder_name"_"$date" created on "$log_date"" | sudo tee -a $log_file
    count=$(shuf -i 1-100 -n1)
    for (( j=1; j<$count; j++))
    do
        if [[ $(df / -BM | grep "/" | awk -F"M" '{ print $3 }') -gt 1024 ]]
        then
            sudo fallocate -l $3 ""$system_folder_name"/"$folder_name"_"$date"/"$file_name"_"$date"."$file_ext""
            log_line=""$system_folder_name"/"$folder_name"/"$file_name"_"$date"."$file_ext" created on "$log_date", size: "$3""
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