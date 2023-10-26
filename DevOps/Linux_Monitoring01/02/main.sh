#!/bin/bash
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

print
echo

echo "Do you want to save the data in a file? (y/n)"
read answer

if [[ $answer = "y" || $answer = "Y" ]]
then 
    filename="$(date "+%d_%m_%y_%H_%M_%S").status"
    print >> $filename
fi

exit 0