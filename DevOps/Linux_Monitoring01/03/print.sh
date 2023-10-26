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
}
