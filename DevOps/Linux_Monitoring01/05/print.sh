#!/bin/bash

function print {
    echo "Total number of folders (including all nested ones) = $(sudo find $DIRECTORY -type d | wc -l)"
    echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
    sudo du -h $DIRECTORY | sort -hr | head -5 | awk 'BEGIN{i=1}{printf "%d - %s, %s\n", i, $2, $1; i++}'
    echo "Total number of files = $(sudo find $DIRECTORY -type f | wc -l)"
    echo "Number of:"
    echo "Configuration files (with the .conf extension) = $(sudo find $DIRECTORY -name '*.conf' | wc -l)"
    echo "Text files = $(sudo find $DIRECTORY -name '*.txt' | wc -l)"
    echo "Executable files = $(sudo find $DIRECTORY -name '*.exe' | wc -l)"
    echo "Log files (with the extension .log) = $(sudo find $DIRECTORY -name '*.log' | wc -l)"
    echo "Archive files = $(sudo find $DIRECTORY -name '*.zip' -name '*.7z' -name '*.rar' -name '*.tar' | wc -l)"
    echo "Symbolic links = $(sudo find $DIRECTORY -type l | wc -l )"
    
    echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"
    TOPFILES=$(sudo find $DIRECTORY -type f -exec du -Sh {} + | sort -rh | head -10 | awk '{printf "%d - %s, %s, \n", NR, $2, $1}')
    TOPEXTENSION=$(sudo find $DIRECTORY -type f -exec du -Sh {} + | sort -rh | head -10 | awk -F '.' 'length($NF)<10 {print $NF}')
    paste -d' ' <(echo "$TOPFILES") <(echo "$TOPEXTENSION")
    
    echo "TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):"
	for i in {1..10}
	do
		fileline=$(sudo find $DIRECTORY -type f -executable -exec du -h {} + | sort -hr | head -10 | sed "${i}q;d")
		if [[ -n $fileline ]]
		then
			echo -e "$i - $(echo $fileline | awk '{print $2}'), $(echo $fileline | awk '{print $1}' | sed -e 's:K: KB:g' | sed -e 's:M: MB:g' | sed -e 's:G: GB:g'), $(md5sum $(echo $fileline | awk '{print $2}') | awk '{print $1}')"
		fi
	done
    
    echo "Script execution time (in seconds) = $TIME"
}