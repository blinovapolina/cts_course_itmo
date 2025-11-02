FROM nginx:alpine

RUN apk add --no-cache openssl && \
    mkdir -p /var/www/websites/test.com \
    /var/www/websites/test2.test.com \
    /var/www/certificates/test.com

COPY index.html /var/www/websites/test.com/
COPY index2.html /var/www/websites/test2.test.com/index.html

COPY static/ /var/www/websites/test.com/static/
COPY static/ /var/www/websites/test2.test.com/static/

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /var/www/certificates/test.com/cert.key \
    -out /var/www/certificates/test.com/cert.crt \
    -subj "/C=RU/ST=State/L=City/O=Organization/CN=test.com"

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
