#!/bin/bash

touch report.html

function page {
    temp=$(sar 1 1 | grep "Average" | sed 's/^.* //')
    cpu=$(echo 100 - $temp | bc)
    echo \# TYPE my_cpu_usage gauge
    echo "my_cpu_usage $cpu" 
    echo \# TYPE my_mem_free gauge
    echo "my_mem_free $(free -m | sed -n 2p | awk '{print $4}')"
    echo \# TYPE my_mem_used gauge
    echo "my_mem_used $(top -b | head -4 | tail +4 | awk '{print $8}')"
    echo \# TYPE my_mem_cache gauge
    echo "my_mem_cache $(top -b | head -4 | tail +4 | awk '{print $10}')"
    echo \# TYPE my_disk_used gauge
    echo "my_disk_used $(df / | tail -n1 | awk '{print $3}')"
    echo \# TYPE my_disk_available gauge
    echo "my_disk_available $(df / | tail -n1 | awk '{print $4}')"
}

while sleep 5
do
    page > report.html
done

# для первого запуска:

#systemctl restart prometheus.service
#touch /home/d06/09/report.html
# echo "events {
#     worker_connections  1024;
# }
# http {
#     include       /etc/nginx/mime.types;
#     default_type  application/octet-stream;
#     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
#                       '$status $body_bytes_sent "$http_referer" '
#                       '"$http_user_agent" "$http_x_forwarded_for"';
#     access_log  /var/log/nginx/access.log  main;
#     server {
#         listen 80;
#         server_name test.nginx.com;
#         root /home/d06/09;
#         index report.html;
#     }
#     sendfile        on;
#     keepalive_timeout  65;
# }" > nginx.conf
# sudo cp nginx.conf /etc/nginx/nginx.conf
# sudo nginx -t
# sudo systemctl restart nginx