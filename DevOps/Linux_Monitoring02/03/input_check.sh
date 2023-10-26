#!/bin/bash

if [ $# != 1 ]
then
    echo "Needs 1 option"
    exit 1
fi

if [ -z "$1" ]
then
    echo "No options found"
    exit 1
fi

if ! [[ $1 =~ ^(1|2|3)$ ]]
then
    echo "The option must be a number between 1 and 3"
    exit 1
fi
