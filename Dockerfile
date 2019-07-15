FROM alpine:latest

MAINTAINER ruslansivets@gmail.com

LABEL version="1.0"
LABEL description="Base environment for Modx"

#set database global environments
ENV MYSQL_DATABASE="modx"
ENV MYSQL_ROOT_PASSWORD="root"
ENV MAX_ALLOWED_PACKET="200M"

# Inslall nginx/php
RUN apk update && apk --no-cache add \
    mariadb mariadb-client mariadb-server-utils \
    nginx \
    php7 php7-fpm php7-json php7-curl php7-zlib php7-xml php7-intl php7-dom \
    php7-iconv php7-xmlreader php7-ctype php-session php7-mysqli && \
    rm -f /var/cache/apk/*

#create directories
RUN mkdir /www
RUN mkdir /run/nginx

#integrate extermal files
COPY ./dockerhelpers/startup.sh /scripts/run.sh
COPY ./dockerhelpers/nginx.conf /etc/nginx/nginx.conf

RUN chmod -R 755 /scripts


VOLUME ["/www"]

ENTRYPOINT ["/scripts/run.sh"]

EXPOSE 80

## run from project root directory
#sudo docker build -t modxbase .
#sudo docker run -p 8080:80 --name modxbase -v ~/projects/ModXHometask:/www -itd modxbase 

