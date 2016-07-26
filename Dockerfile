FROM php:7.0-fpm

MAINTAINER "billqiang" <whenjonny@gmail.com>

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install zip \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install pod_mysql \
    && docker-php-ext-install gd \
    && docker-php-ext-install curl

COPY libs/redis-3.0.0.tgz /home/redis.tgz
COPY libs/mongodb-1.1.8.tgz /home/mongo.tgz
COPY libs/swoole-1.8.7.tgz /home/swoole.tgz

RUN pecl install /home/redis.tgz && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
        && pecl install /home/mongo.tgz && echo "extension=mongo.so" > /usr/local/etc/php/conf.d/mongo.ini \
        && pecl install /home/swoole.tgz && echo "extension=swoole.so" > /usr/local/etc/php/conf.d/swoole.ini

# PHP config
ADD php.ini         /usr/local/etc/php/php.ini
ADD php-fpm.conf    /usr/local/etc/php-fpm.conf

# Composer
ADD composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer

WORKDIR /data/code/web

# Write Permission
RUN usermod -u 1000 www-data

EXPOSE 9000
VOLUME ["/data"]
