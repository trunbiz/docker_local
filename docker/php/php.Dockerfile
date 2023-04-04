FROM php:8.0-fpm
#FROM php:7.3-fpm


RUN apt-get update && apt-get install -y \
    libmcrypt-dev \
    openssl \
    curl \
    git vim unzip cron \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    pdo_mysql \
    tokenizer

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g n \
    && n stable

RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install supervisor
RUN apt-get update && apt-get install -y supervisor
#COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install zsh
RUN sh -c "$(curl https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -- \
  -t ys \
  -p https://github.com/zsh-users/zsh-syntax-highlighting \
  -p https://github.com/zsh-users/zsh-history-substring-search

## Install Kafka
#RUN apt-get update && pecl install rdkafka

## Install Extension
#RUN docker-php-ext-install sockets

#RUN apt-get update -y \
#  && apt-get install -y \
#     libxml2-dev \
#  && apt-get clean -y \
#  && docker-php-ext-install soap

# Install mongo
RUN pecl install mongodb \
&& echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/ext-mongodb.ini

COPY config/php.ini /usr/local/etc/php/

#ADD etc/docker-php.ini $PHP_INI_DIR/conf.d/
#ADD etc/docker-php-xdebug.ini $PHP_INI_DIR/conf.d/zz-xdebug-settings.ini
#
#ADD php.docker-entroypoint.sh /usr/local/bin/
#
#RUN ["chmod", "+x", "/usr/local/bin/php.docker-entroypoint.sh"]
#
#ENTRYPOINT [ "/usr/local/bin/php.docker-entroypoint.sh" ]

CMD ["php-fpm"]
