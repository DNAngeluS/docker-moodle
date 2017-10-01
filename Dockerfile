FROM php:7-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
	libtool \
	libcurl4-gnutls-dev \
	libxmlrpc-core-c3-dev \
	libzip-dev \
	libpcre3-dev \
	libxml2-dev \
	libicu-dev \
	libpq-dev \
	postgresql-client \
	cron \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install -j$(nproc) \
	iconv \
	mcrypt \
	tokenizer \
	xmlrpc \
	soap \
	ctype \
	zip \
	simplexml \
	dom \
	xml \
	intl \
	json \
	sockets \
	opcache \
	pdo \
	pdo_pgsql \
	pgsql \
	gd
#    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#    && docker-php-ext-install -j$(nproc) gd \

ENV MOODLE_VERSION 33
ENV MOODLE_SHA256 b2ba30f5d6ca434dee8fa8d268b294bfb428bd095ec32c6e96f84079254ccf45

VOLUME /app
VOLUME /data

RUN set -ex; \
	curl -o moodle.tgz -fSL "https://download.moodle.org/download.php/direct/stable${MOODLE_VERSION}/moodle-latest-${MOODLE_VERSION}.tgz"; \
	echo "$MOODLE_SHA256 *moodle.tgz" | sha256sum -c -; \
# upstream tarballs include ./moodle/ so this gives us /usr/src/moodle
	tar -xf moodle.tgz -C /usr/src/; \
	rm moodle.tgz; \
	chown -R root:www-data /usr/src/moodle

#RUN set -ex; \
#	chown -R root:www-data /data; \
#	chmod -R 775 /app/moodle /data; \
#	rmdir /var/www/html; \
#	ln -s /app/moodle /var/www/html; \
#	echo "* * * * *    /usr/bin/php /var/www/html/admin/cli/cron.php > /dev/null" > /app/cron; \
#	crontab /app/cron
WORKDIR /app

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apache2-foreground"]
