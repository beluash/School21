#!/bin/bash

if [ -z "$1" ]
then
    echo "No options found."
    exit 1
elif [ $# -gt 1 ]
then
    echo "Too many options."
    exit 1
elif [[ ! -d "$1" ]]
then
    echo "No such directory."
    exit 1
fi