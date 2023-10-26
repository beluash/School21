#!/bin/bash

reg="^[1-6]$"

if [ $# -gt 0 ]
then
    echo "Too many options."
    exit 1
fi

if [[ $column1_background == $column1_font_color ]] || 
   [[ $column2_background == $column2_font_color ]]
then
    echo "You should choose different colors for each column. Try again with another numbers."
    exit 1
fi

if ! [[ $column1_background =~ $reg ]] || ! [[ $column1_font_color =~ $reg ]] || 
   ! [[ $column2_background =~ $reg ]] || ! [[ $column2_font_color =~ $reg ]]
then
    echo "Options must contain only digits (1-6)."
    if ! [[ $column1_background =~ $reg ]]; then default1=1; column1_background=$default_column1_background; fi
    if ! [[ $column1_font_color =~ $reg ]]; then default2=1; column1_font_color=$default_column1_font_color; fi
    if ! [[ $column2_background =~ $reg ]]; then default3=1; column2_background=$default_column2_background; fi
    if ! [[ $column2_font_color =~ $reg ]]; then default4=1; column2_font_color=$default_column2_font_color; fi
fi