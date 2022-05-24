FROM php:7.4-apache

ENV MOODLE_VERSION 400

RUN apt-get update && apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
		libtool \
		libcurl4-gnutls-dev \
		libxmlrpc-core-c3-dev \
		libzip-dev \
		libpcre3-dev \
		libxml2-dev \
		libicu-dev \
		libpq-dev \
		libsodium-dev \
		mysql-common \
		mariadb-client \				
		postgresql-client \
		cron \
		&& rm -rf /var/lib/apt/lists/* \
		&& docker-php-ext-install -j$(nproc) \
		iconv \
		tokenizer \
		soap \
		ctype \
		exif \
		zip \
		dom \
		xml \
		simplexml \
		intl \
		json \
		sockets \
		opcache \
		mysqli \
		pgsql \	
		pdo \
		pdo_mysql \
		pdo_pgsql \	 
		xmlrpc \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

VOLUME [ "/srv/www/moodle", "/var/moodle/data"]

# Download and Install last Moodle Version
RUN set -ex; \
	curl -o moodle.tgz -fSL "https://download.moodle.org/download.php/direct/stable${MOODLE_VERSION}/moodle-latest-${MOODLE_VERSION}.tgz"; \
	curl "https://download.moodle.org/stable${MOODLE_VERSION}/moodle-latest-${MOODLE_VERSION}.tgz.sha256" | awk '{print $2 " *moodle.tgz"}' | sha256sum -c -; \
	# upstream tarballs include ./moodle/ so this gives us /usr/src/moodle
	tar -xf moodle.tgz -C /usr/src/; \
	rm moodle.tgz; \
	chown -R www-data:www-data /usr/src/moodle/

# Use the default production configuration
RUN set -ex; \
	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
	echo "max_input_vars = 5000" > /usr/local/etc/php/conf.d/moodle-conf.ini; \
	rm -rf /var/www/html; \
	ln -sf /srv/www/moodle /var/www/html

WORKDIR /srv/www/moodle

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apache2-foreground"]
