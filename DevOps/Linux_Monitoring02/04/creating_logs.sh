#!/bin/bash

function creating_info_files {
    touch methods.txt url.txt protocol.txt codes.txt agents.txt
    printf "GET\nPOST\nPUT\nPATCH\nDELETE" > methods.txt
    printf "200\n201\n400\n401\n403\n404\n500\n501\n502\n503" > codes.txt
    printf "HTTP/1.1\nHTTP/1.0\nHTTP/2" > protocol.txt
    printf "/news\n/download\n/faq\n/books" > url.txt

    printf "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0\n`
           `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36\n`
           `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41\n`
           `Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1\n`
           `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59\n`
           `Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)\n`
           `curl/7.64.1\n`
           `Mozilla/5.0 (Windows NT 10.0; Trident/7.0; rv:11.0) like Gecko" > agents.txt
}

function logs {
    for (( count=1; count <= 5; count++ ))
    do
        day=$(shuf -i 1-$(date +%d) -n1)
        count_note=$(shuf -i 100-1000 -n1)
        for (( i = 0; i < count_note; i++ ))
        do
            # "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\""
            # 1) IP (любые корректные, т.е. не должно быть ip вида 999.111.777.777)
            printf "$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1).$(shuf -i 1-255 -n1)" >> $count.log
            printf " - - " >> $count.log
            # 4) Даты (в рамках заданного дня лога, должны идти по увеличению)
            printf "[$day$(date +/%b/%Y:$(shuf -n1 -i 1-23):$(shuf -n1 -i 1-59):$(shuf -n1 -i 1-59)) $(date +%z)] " >> $count.log
            # 3) Методы (GET, POST, PUT, PATCH, DELETE)
            printf "\"$(shuf -n1 methods.txt) " >> $count.log
            # 5) URL запроса агента
            printf "$(shuf -n1 url.txt) " >>$count.log
            printf "$(shuf -n1 protocol.txt)\" " >>$count.log
            # 2) Коды ответа (200, 201, 400, 401, 403, 404, 500, 501, 502, 503)
            printf "$(shuf -n1 codes.txt) " >>$count.log
            printf $RANDOM >>$count.log
            printf " \"https://nginx.org/ru/\" " >>$count.log
            # 6) Агенты (Mozilla, Google Chrome, Opera, Safari, Internet Explorer, Microsoft Edge, Crawler and bot, Library and net tool)
            echo "\"$(shuf -n1 agents.txt)\"" >>$count.log
        done
    done
}

function clean {
    sudo rm -rf methods.txt
    sudo rm -rf url.txt
    sudo rm -rf protocol.txt
    sudo rm -rf codes.txt
    sudo rm -rf agents.txt
}

# 200 - OK — успешный запрос
# 201 - Created — Создан новый ресурс
# 400 - Bad Request — Плохой запрос
# 401 - Unauthorized — Требуется аутентификация
# 403 - Forbidden — Ограничение в доступе
# 404 - Not Found —  Не найден
# 500 - Internal Server Error — Внутренняя ошибка сервера
# 501 - Not Implemented — Не выполненно
# 502 - Bad Gateway — Плохой шлюз
# 503 - Service Unavailable — Сервис недоступен