#!/bin/bash

COLOR=(
    '0'  #default
    '37' #white
    '31' #red
    '32' #green
    '36' #cyan
    '35' #magenta
    '30' #black
)

function set_colors {
    echo "\033[$((${COLOR[$1]} + 10))m\033[${COLOR[$2]}m"
}