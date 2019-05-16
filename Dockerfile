FROM php:5.6-alpine

LABEL maintainer="Daniel Llewellyn <daniel@bowlhat.net>"

WORKDIR /var/www/html

ENV peclBuildDeps=" \
        autoconf \
        file \
        g++ \
        gcc \
        libressl-dev \
        libxml2-dev \
        make \
    " \
    peclRunDeps=" \
        libressl \
    " \
    extensionBuildDeps=" \
        autoconf \
        gcc \
        mariadb-dev \
        libpng-dev \
        libressl-dev \
        libxml2-dev \
        libzip-dev \
        make \
        rsync \
    " \
    extensionRunDeps=" \
        libpng \
        libressl \
        libzip \
        mariadb-client \
    " \
    extensions=" \
        gd \
        mysqli \
        soap \
        zip \
    "

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        $extensionBuildDeps \
    && docker-php-ext-install $extensions \
    && apk add --no-cache --virtual .extension-rundeps $extensionRunDeps \
    && apk del .build-deps

RUN set -xe \
    && apk add --no-cache --virtual .build-deps $peclBuildDeps \
    # pecl install memcached && echo extension=memcached > $PHP_INI_DIR/conf.d/ext-memcached.ini \ # disabled due to old incompatible PHP release
    && apk add --no-cache --virtual .rundeps $peclRunDeps \
    && apk del .build-deps

RUN set -xe \
    && apk add --no-cache --virtual .rundeps \
        bash \
        ca-certificates \
        curl \
        git \
        less \
        libmcrypt \
        libpng \
        libsodium \
        libxml2 \
        mariadb \
        openssh \
        subversion \
        wget

RUN set -xe \
    && mysql_install_db --user=mysql --datadir=/var/lib/mysql

RUN curl -SL "https://phar.phpunit.de/phpunit-5.phar" -o phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/bin/phpunit \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
