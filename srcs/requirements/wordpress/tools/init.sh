#!/bin/bash

#Exit the script immediately if any command returns a non-zero (error) status.
set -e

WP_PATH=/var/www/html

# Read Secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Wait for MariaDB
while ! mysqladmin ping \
	-h "mariadb" \
	-u "$MYSQL_USER" \
	-p"$MYSQL_PASSWORD" \
	--silent >/dev/null 2>&1; do

	echo "Waiting for MariaDB..."
	sleep 2

done

echo "MariaDB is ready"

# Check if WordPress is already installed
if ! wp core is-installed \
	--path="$WP_PATH" \
	--allow-root; then
	echo "Installing WordPress..."

	# download wp
	wp core download \
		--path="$WP_PATH" \
		--allow-root

	# create wp-config.php
	wp config create \
		--path="$WP_PATH" \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="mariadb" \
		--allow-root

	# install wp
	wp core install \
		--path="$WP_PATH" \
		--url="$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--allow-root

	# Create regular user if it does not already exist
	if ! wp user get "$WP_USER" \
		--path="$WP_PATH" \
		--allow-root >/dev/null 2>&1; then

	echo "Creating WordPress user ${WP_USER}..."

	wp user create \
		"$WP_USER" \
		"$WP_USER_EMAIL" \
		--path="$WP_PATH" \
		--user_pass="$WP_USER_PASSWORD" \
		--role=subscriber \
		--allow-root

else
	echo "Wordpress already installed."
fi

# Start php-fpm
echo "Starting PHP-FPM..."
# -F for forground
exec php-fpm8.2 -F
