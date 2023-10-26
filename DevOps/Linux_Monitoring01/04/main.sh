#!/bin/bash
. colors.config

default1=0
default2=0
default3=0
default4=0

default_column1_background=6
default_column1_font_color=5
default_column2_background=6
default_column2_font_color=5

. checks_for_options.sh

column1_background=${column1_background:=${default_column1_background}}
column1_font_color=${column1_font_color:=${default_column1_font_color}}
column2_background=${column2_background:=${default_column2_background}}
column2_font_color=${column2_font_color:=${default_column2_font_color}}

. set_colors.sh
. print.sh

HOSTNAME=$(hostname)
TIMEZONE="$(cat /etc/timezone) $(date +"%Z" -u) $(date +"%:::z")"
USER=$(whoami)
OS=$(lsb_release -d | awk '{printf("%s %s\n", $2, $3)}')
DATE=$(date +"%d %B %Y %X")
UPTIME=$(uptime -p)
UPTIME_SEC=$(cat /proc/uptime | awk '{print $1}')
IP=$(hostname -I)
MASK=$(ifconfig | grep -m1 netmask | awk '{print $4}')
GATEWAY=$(ip r | grep default | awk '{print $3}')
RAM_TOTAL=$(free -m | awk '/Mem:/{printf "%.3f GB", $2/1024}')
RAM_USED=$(free -m | awk '/Mem:/{printf "%.3f GB", $3/1024}')
RAM_FREE=$(free -m | awk '/Mem:/{printf "%.3f GB", $4/1024}')
SPACE_ROOT=$(df /root/ | awk '/\/$/ {printf "%.2f MB", $2/1024}')
SPACE_ROOT_USED=$(df /root/ | awk '/\/$/ {printf "%.2f MB", $3/1024}')
SPACE_ROOT_FREE=$(df /root/ | awk '/\/$/ {printf "%.2f MB", $4/1024}')

color1=$(set_colors ${column1_background} ${column1_font_color})
color2=$(set_colors ${column2_background} ${column2_font_color})
default_color=$(set_colors 0 0)

print

exit 0