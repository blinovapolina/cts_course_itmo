# Лабоработрная работа №1

В данной лабораторной работе мы научимся настраивать веб-сервер Nginx для работы с несколькими pet-проектами, а также проверим возможные уязвимости в конфигурации.

## Конфиг Nginx

### Реализованные функции

- Редирект 80 на 443
- Https работает с ssl сертификатом
- Используется alias
- Прописаны виртуальные хосты под два тестовых проекта

### Конфиг

```nginx
server {
    listen 443 ssl;

    # Файлы сертификата
    ssl_certificate /var/www/certificates/test.com/cert.crt;
    ssl_certificate_key /var/www/certificates/test.com/cert.key;

    # домен проекта
    server_name test.com;

    # тут храним статичные файлы сайта
    root /var/www/websites/test.com;

    # идекс файл - index.html
    index index.html;

    # главный роут, если файл индекса не найден - кидаем на 404
    location / {
        try_files $uri $uri/ =404;
    }

    # robots.txt для поисковых систем
    location /robots.txt {
        alias /var/www/websites/test.com/static/robots.txt;
        default_type text/plain;
        add_header Content-Disposition 'inline';
    }
}

server {
    listen 80;
    server_name test.com;

    # редиректим на https
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;

    ssl_certificate /var/www/certificates/test.com/cert.crt;
    ssl_certificate_key /var/www/certificates/test.com/cert.key;

    server_name test2.test.com;
    root /var/www/websites/test2.test.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}

server {
    listen 80;
    server_name test2.test.com;
    return 301 https://$host$request_uri;
}
```

### Docker

Тестовые html файлы и конфиг nginx завернем в Docker контейнер

```Dockerfile
# Используем alpine (минимальный образ, чтобы не загружать систему)
FROM nginx:alpine

# Обоновляемся, ставим openssl и создаем папки
RUN apk update && \
    apk add --no-cache openssl && \
    mkdir -p /var/www/websites/test.com \
    /var/www/websites/test2.test.com \
    /var/www/certificates/test.com

# Копируем статичные файлы
COPY index.html /var/www/websites/test.com/
COPY index2.html /var/www/websites/test2.test.com/

COPY static/ /var/www/websites/test.com/static/
COPY static/ /var/www/websites/test2.test.com/static/

# Делаем самоподписный ssl сертификат
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /var/www/certificates/test.com/cert.key \
    -out /var/www/certificates/test.com/cert.crt \
    -subj "/C=RU/ST=State/L=City/O=Organization/CN=test.com"

COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем нужные порты
EXPOSE 80 443

# Стартуем nginx
CMD ["nginx", "-g", "daemon off;"]
```

Для проверки работы сайта нам нужно отредактировать хосты на своем пк:

```bash
nano /etc/hosts

# ----

127.0.0.1 test.com
127.0.0.1 test2.test.com
```

Теперь при открытии test.com у нас будет открываться наша локальная версия, а не идти запрос через dns (например 1.1.1.1) и потом к рельному test.com.

### Проверка работы

<img width="1512" height="905" alt="Снимок экрана 2025-11-02 в 22 45 34" src="https://github.com/user-attachments/assets/361022aa-c972-47e9-9fae-09ae1021b18b" />
<img width="1512" height="905" alt="Снимок экрана 2025-11-02 в 22 45 20" src="https://github.com/user-attachments/assets/7e60d101-784b-4b95-9023-6b02e6125a84" />
<img width="1302" height="433" alt="image" src="https://github.com/user-attachments/assets/d458a71d-c03c-43f6-8aae-9ebc46c8c840" />


## Задание под звездочкой

### Уязвимый сайт

Я выбрала сайт продажи электронной техники: https://xn----7sbbbucvqex7cwb4i.xn--p1ai/

### Анализ

Заходим на главную страницу сайта и анализируем какие сайт использует технологии при помощи расширения Wappalyzer, видим, что сайт использует cms Bitrix.
<img width="584" height="638" alt="image" src="https://github.com/user-attachments/assets/4d35ac81-5067-4c59-913c-060d8ffd1224" />

Гуглим дефолтный путь к админ панели Bitrix и находим: /bitrix/admin

<img width="608" height="125" alt="image" src="https://github.com/user-attachments/assets/34061bb1-4bd3-46ed-816d-a01d8211c254" />

По идее, доступ к подобным админ панелям должен быть недоступен для внешнего пользователя, но в нашем случае доступ открыт для всех:
https://xn----7sbbbucvqex7cwb4i.xn--p1ai/bitrix/admin


<img width="726" height="810" alt="image" src="https://github.com/user-attachments/assets/672f1d40-9247-4c2c-8441-73357430de3b" />

### Решение

Решается все элементарно

В конфиге nginx разрешим доступ к пути /bitrix/admin только юезрам с определенным ip адресом

```nginx
# Разрешаем только 127.0.0.1
geo $allowed_ips {
    default   0;
    127.0.0.1 1;
}

server {
    listen 443 ssl;

    ssl_certificate /var/www/certificates/test.com/cert.crt;
    ssl_certificate_key /var/www/certificates/test.com/cert.key;

    # Домен на русском
    server_name xn----7sbbbucvqex7cwb4i.xn--p1ai;

    # Защищаем роут админ панели
    location /bitrix/admin {
        if ( $allowed_ips = 0 ) { return 404; }
        # оставшийся конфиг
    }

    # оставшийся конфиг
}
```

В этом конфиге мы указали список разрешенных ip адресов в geo $allowed_ips (127.0.0.1) и добавили в роут /bitrix/admin условие, которое будет проверять ip пользователя и если его нет в списке разрешенных выдавать 404 ошибку (не найдено). Это предовратит попытки брутфорса пароля администратора.

Также можно заменить логику фильтрации по IP, например, проверкой заголовка password и если в нем будет указан верный пароль, будем пропускать юзера на роут.
