# Base image
FROM debian:bookworm

# Environment variables
# None required for build-time

# Install dependencies
# PHP-FPM: FastCGI process manager that executes WordPress PHP files.
# PHP extensions:
#   - php-mysql: allows PHP to communicate with MariaDB.
#   - php-curl: enables HTTP requests used by WordPress and plugins.
#   - php-gd: provides image processing (resizing imgs/generating thumbnails etc).
#   - php-mbstring: handles multibyte character strings.
#   - php-xml: provides XML parsing functionality.
#   - php-zip: allows handling compressed files and plugin/theme packages.
# mariadb-client: provides database client tools for testing MariaDB connectivity.
# curl/wget: utilities used to download WordPress and wp-cli.
# unzip: extracts downloaded archives.
RUN apt-get update && \
    apt-get upgrade -y && \
	apt-get install -y \
	php8.2-fpm \
	php8.2-mysql \
	php8.2-curl \
	php8.2-gd \
	php8.2-mbstring \
	php8.2-xml \
	php8.2-zip \
	mariadb-client \
	curl \
	wget \
	unzip \
	&& apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Configuration

# Application setup
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Volumes (optional)
VOLUME /var/www/html

# Ports (documentaion only)
EXPOSE 9000

# Startup
ENTRYPOINT ["/usr/local/bin/init.sh"]
