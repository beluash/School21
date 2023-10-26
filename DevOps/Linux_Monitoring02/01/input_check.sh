#!/bin/bash

if [ $# != 6 ]
then
    echo "Needs 6 options"
    exit 1
fi

if [ -z "$1" ]
then
    echo "No options found"
    exit 1
fi

if ! [ -d "$1" ]
then
    echo "Incorrect PATH"
    exit 1
fi

if [[ $2 != [[:digit:]] ]]
then
    echo "The second option must be a number"
    exit 1
fi

if ! [[ $3 =~ ^[a-zA-Z]{1,7}$ ]]
then
    echo "The third option must be a set of letters (not more than 7)"
    exit 1
fi

if [[ $4 != [[:digit:]] ]]
then
    echo "The fourth option must be a number"
    exit 1
fi

if [[ !$5 =~ ^[a-zA-Z]{1,7}[.][a-zA-Z]{1,3}+$ ]]
then
    echo "The fifth option must be a set of letters (not more than 7 before dot and not more than 3 after)"
    exit 1
fi

if ! [[ $6 =~ ^([1-9][0-9]?|100)kb$ ]]
then
    echo "The sixth option must be a number not more than 100"
    exit 1
fi