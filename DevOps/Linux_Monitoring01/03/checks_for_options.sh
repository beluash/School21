#!/bin/bash

reg="^[1-6]$"

if [ -z "$1" ]
then
    echo "No options found."
    exit 1
elif [ $# -lt 4 ]
then
    echo "Too few options."
    exit 1
elif [ $# -gt 4 ]
then
    echo "Too many options."
    exit 1
elif ! [[ $1 =~ $reg ]] || ! [[ $2 =~ $reg ]] || ! [[ $3 =~ $reg ]] || ! [[ $4 =~ $reg ]]
then
    echo "Options must contain only digits (1-6)."
    exit 1
elif [[ $1 == $2 ]] || [[ $3 == $4 ]]
then
    echo "You should choose different colors for each column. Try again with another numbers."
    exit 1
fi