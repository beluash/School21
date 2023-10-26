#!/bin/bash
if [[ $1 != [[:alpha:]] ]]
then
    echo "Options must contain only letters."
    exit 1
else 
    echo $1
fi