FROM php:7.2-fpm-stretch

# Install other missed extensions
RUN apt-get update && apt-get install -y \
      mc \
      vim \
      zlib1g-dev \
      libaio-dev \
      libxml2-dev \
      librabbitmq-dev \
      curl \
      gnupg \
      libyaml-0-2 libyaml-dev \
      git \
      apt-transport-https  \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
	echo 'deb https://deb.nodesource.com/node_10.x stretch main' > /etc/apt/sources.list.d/nodesource.list && \
	echo 'deb-src https://deb.nodesource.com/node_10.x stretch main' >> /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs npm

RUN curl https://getcaddy.com | bash -s personal hook.service,http.cache,http.cgi,http.expires,http.minify

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

RUN pecl channel-update pecl.php.net \
    && pecl install yaml-2.0.0 \
    && docker-php-ext-enable yaml

RUN docker-php-ext-install pdo_mysql intl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

COPY ./caddy /etc/caddy

COPY ./beta.blog /var/www

WORKDIR /var/www/beta.blog

RUN npm install

RUN echo 'alias ll="ls -al"' >> ~/.bashrc \
    && mkdir -p /var/log/php/tracy && chown -R www-data /var/log/php && chmod +w /var/log/php

ENV PROJECT_ENVIRONMENT dev

COPY docker.sh /

ENTRYPOINT ["sh", "/docker.sh"]

EXPOSE 80