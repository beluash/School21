#!/bin/bash

function print {
    echo -e "${color1}HOSTNAME${default_color} = ${color2}$HOSTNAME${default_color}"
    echo -e "${color1}TIMEZONE${default_color} = ${color2}$TIMEZONE${default_color}"
    echo -e "${color1}USER${default_color} = ${color2}$USER${default_color}"
    echo -e "${color1}OS${default_color} = ${color2}$OS${default_color}"
    echo -e "${color1}DATE${default_color} = ${color2}$DATE${default_color}"
    echo -e "${color1}UPTIME${default_color} = ${color2}$UPTIME${default_color}"
    echo -e "${color1}UPTIME_SEC${default_color} = ${color2}$UPTIME_SEC${default_color}"
    echo -e "${color1}IP${default_color} = ${color2}$IP${default_color}"
    echo -e "${color1}MASK${default_color} = ${color2}$MASK${default_color}"
    echo -e "${color1}GATEWAY${default_color} = ${color2}$GATEWAY${default_color}"
    echo -e "${color1}RAM_TOTAL${default_color} = ${color2}$RAM_TOTAL${default_color}"
    echo -e "${color1}RAM_USED${default_color} = ${color2}$RAM_USED${default_color}"
    echo -e "${color1}RAM_FREE${default_color} = ${color2}$RAM_FREE${default_color}"
    echo -e "${color1}SPACE_ROOT${default_color} = ${color2}$SPACE_ROOT${default_color}"
    echo -e "${color1}SPACE_ROOT_USED${default_color} = ${color2}$SPACE_ROOT_USED${default_color}"
    echo -e "${color1}SPACE_ROOT_FREE${default_color} = ${color2}$SPACE_ROOT_FREE${default_color}"

    if [[ $default1 -eq 1 ]]; then echo "Column 1 background = default (black)"; else 
        echo "Column 1 background = ${column1_background} (${COLOR_NAMES[${column1_background}]})"; fi
    if [[ $default2 -eq 1 ]]; then echo "Column 1 font color = default (red)"; else
        echo "Column 1 font color = ${column1_font_color} (${COLOR_NAMES[${column1_font_color}]})"; fi
    if [[ $default3 -eq 1 ]]; then echo "Column 2 background = default (red)"; else
        echo "Column 2 background = ${column2_background} (${COLOR_NAMES[${column2_background}]})"; fi
    if [[ $default4 -eq 1 ]]; then echo "Column 2 font color = default (black)"; else
        echo "Column 2 font color = ${column2_font_color} (${COLOR_NAMES[${column2_font_color}]})"; fi
}
