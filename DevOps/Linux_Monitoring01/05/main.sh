#!/bin/bash

START=`date +%s.%N`

# MD5=(
#     0, 0, 0, 0, 0, 0, 0, 0, 0, 0
# )

. print.sh
. checks_for_options.sh

DIRECTORY=$1


#   for num in {1..10}
#   do
#       file_line=$(find $1 2>/dev/null -type f -exec du -h {} + | sort -rh | head -10 | sed "${num}q;d")
#       if ! [[ -z $file_line ]]
#       then
#           echo -n "$num - "
#           echo -n "$(echo $file_line | awk '{print $2}'), "
#           echo -n "$(echo $file_line | awk '{print $1}'), "
#           echo "$(echo $file_line | grep -m 1 -o -E "\.[^/.]+$" | awk -F . '{print $2}')"

END=`date +%s.%N`
TIME=$(echo "$END - $START" | bc -l)

print

exit 0