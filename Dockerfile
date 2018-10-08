FROM php:7.1

LABEL maintainer="Daniel Llewellyn <daniel@bowlhat.net>"

WORKDIR /var/www/html

ENV peclDeps=" \
        autoconf \
        gcc \
        libmemcached-dev \
        libssl-dev \
        libxml2-dev \
        make \
        zlib1g-dev \
    " \
    extensionDeps=" \
        autoconf \
        default-libmysqlclient-dev \
        gcc \
        libpng-dev \
        libsodium-dev \
        libssl-dev \
        libxml2-dev \
        make \
        rsync \
    " extensions=" \
        gd \
        mbstring \
        mysqli \
        soap \
        sodium \
        zip \
    "

RUN apt-get update \
    && apt-get install -yqq --no-install-recommends $extensionDeps \
    && docker-php-ext-install $extensions \
    && apt-get purge -yqq --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $extensionDeps \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -yqq --no-install-recommends $peclDeps \
    && pecl install memcached && echo extension=memcached > $PHP_INI_DIR/conf.d/ext-memcached.ini \
    && apt-get purge -yqq --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $peclDeps \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -yqq --no-install-recommends \
        ca-certificates \
        curl \
        git \
        less \
        libmcrypt4 \
        libmemcached11 \
        libmemcachedutil2 \
        libpng16-16 \
        libsodium18 \
        libxml2 \
        mysql-server \
        ssh \
        subversion \
        wget \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock \
    && service mysql start \
    && mysql --user="root" --execute="CREATE DATABASE test;"

RUN curl -SL "https://phar.phpunit.de/phpunit-6.phar" -o phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/bin/phpunit \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
