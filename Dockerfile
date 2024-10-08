#docker build -t misaelgomes/php8.3-vips-swoole .

FROM php:8.3.11

LABEL maintainer="Misael Gomes"
LABEL description="PHP8.3 VIPS Swoole, mongodb, redis, cron, imagem base para criação de outros containers"

ARG WWWGROUP

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=America/Sao_Paulo

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN usermod -u 1000 www-data

RUN apt-get update -y && apt-get upgrade --fix-missing -y && apt-get install -y webp libwebp-dev gifsicle jpegoptim \
    libfreetype6-dev libpng-dev libvips42 librsvg2-bin \
    fswatch ffmpeg libffi-dev libvips libvips-dev libvips-tools cron
RUN apt-get install -y curl ca-certificates zip unzip git supervisor \
    openssl curl libonig-dev tzdata libxslt-dev tar zip unzip zlib1g-dev zlib1g libzip-dev libbz2-dev

RUN apt-get install -y libcurl4-openssl-dev pkg-config libssl-dev

RUN apt-get install -y libsnappy-dev libzstd-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

RUN docker-php-ext-install gd soap pdo_mysql opcache mbstring \
        mysqli gettext calendar bz2 exif gettext \
        sockets sysvmsg sysvsem sysvshm xsl zip xml intl bcmath ffi pcntl

RUN pecl channel-update pecl.php.net &&  echo yes | pecl install vips igbinary redis swoole zstd lzf mongodb

RUN docker-php-ext-enable igbinary redis lzf zstd vips swoole mongodb

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get install -y nano

RUN apt-get -y autoremove && apt-get clean 
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*