#!/bin/bash

if [ $# != 3 ]
then
    echo "Needs 3 options"
    exit 1
fi

if [ -z "$1" ]
then
    echo "No options found"
    exit 1
fi

if ! [[ $1 =~ ^[a-zA-Z]{1,7}$ ]]
then
    echo "The first option must be a set of letters (not more than 7)"
    exit 1
fi

if ! [[ $2 =~ ^[a-zA-Z]{1,7}[.][a-zA-Z]{1,3}+$ ]]
then
    echo "The second option must be a set of letters (not more than 7 before dot and not more than 3 after)"
    exit 1
fi

if ! [[ $3 =~ ^([1-9][0-9]?|100)Mb$ ]]
then
    echo "The third option must be a number not more than 100"
    exit 1
fi