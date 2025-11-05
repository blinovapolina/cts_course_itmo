#!/bin/bash
if [ -f ".env" ]; then
    > .env
else
   touch .env
fi

echo "Let's set environmental variables"

DB_VARS=("DB_NAME" "DB_USER" "DB_PASS" "DB_HOST")

for i in ${DB_VARS[@]}; do
    read -p "$i{default=postgres}: " $i
done

for i in ${DB_VARS[@]}; do
    if [[ -n "${!i}" ]]; then echo "$i=$(echo ${!i})" >> .env; fi
done

read -p "DB_PORT{default=5432}: " DB_PORT && if [[ -n $DB_PORT ]]; then echo "DB_PORT=$(echo $DB_PORT)" >> .env; fi
read -p "RABBITMQ_DEFAULT_USER{default=admin}: " RABBITMQ_DEFAULT_USER && if [[ -n $RABBITMQ_DEFAULT_USER ]]; then echo "RABBITMQ_DEFAULT_USER=$(echo $RABBITMQ_DEFAULT_USER)" >> .env; fi
read -p "RABBITMQ_DEFAULT_PASS{default=mypass}: " RABBITMQ_DEFAULT_PASS && if [[ -n $RABBITMQ_DEFAULT_PASS ]]; then echo "RABBITMQ_DEFAULT_PASS=$(echo $RABBITMQ_DEFAULT_PASS)" >> .env; fi
read -p "AMQP_HOST_STRING{default=amqp://admin:mypass@rabbitmq:5672/}: " AMQP_HOST_STRING && if [[ -n $AMQP_HOST_STRING ]]; then echo "AMQP_HOST_STRING=$(echo $AMQP_HOST_STRING)" >> .env; fi
read -p "COOKIES_SECURE{default=True}: " COOKIES_SECURE && if [[ -n $COOKIES_SECURE ]]; then echo "COOKIES_SECURE=$(echo $COOKIES_SECURE)" >> .env; fi
read -p "DOMAIN (starting with scheme. Ex. https://portal-demo.whitespots.io): " DOMAIN && if [[ -n $DOMAIN ]]; then echo "DOMAIN=$(echo $DOMAIN)" >> .env; fi
read -p "IMAGE_VERSION: " IMAGE_VERSION && if [[ -n $IMAGE_VERSION ]]; then echo "IMAGE_VERSION=$(echo $IMAGE_VERSION)" >> .env; fi

echo

openssl genrsa -out jwt-private.pem 2048
openssl rsa -in jwt-private.pem -pubout -outform PEM -out jwt-public.pem

sed -i -e ' 1 s/.*/&\\n/' jwt-public.pem jwt-private.pem
sed -i -e '$s/^/\\n/' jwt-public.pem jwt-private.pem

JWT_PRIVATE_KEY=$(tr -d '\n' < jwt-private.pem)
JWT_PUBLIC_KEY=$(tr -d '\n' < jwt-public.pem)
echo "JWT_PRIVATE_KEY=$JWT_PRIVATE_KEY" >> .env
echo "JWT_PUBLIC_KEY=$JWT_PUBLIC_KEY" >> .env

SECRET_KEY=$(openssl rand -base64 30)
echo "SECRET_KEY=$SECRET_KEY" >> .env
echo

rm jwt*
