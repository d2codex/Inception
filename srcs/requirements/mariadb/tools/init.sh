#!/bin/bash

# Exit immediately if a command fails.
set -e

# Create MariaDB runtime directory for Unix socket.
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Read passwords from Docker secrets.
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

echo "Database configuration loaded."

# Check if MariaDB has already been initialized.

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB..."

	mariadb-install-db \
		--user=mysql \
		--datadir=/var/lib/mysql

	# Start temporary MariaDB server for initial database setup.
	# This server only uses a local Unix socket.
	# Networking is disabled because WordPress is not connected yet.
	echo "Starting temporary MariaDB..."

	mysqld \
		--user=mysql \
		--skip-networking \
		--socket=/tmp/mysql.sock &

	pid="$!"

	# Wait until the temporary MariaDB server is ready.
	until mariadb-admin \
		--socket=/tmp/mysql.sock \
		ping >/dev/null 2>&1; do

		sleep 1

	done

	echo "MariaDB temporary server is ready"
	echo "Configuring database and users..."

	# Create database, user and permissions.
	mariadb \
		--socket=/tmp/mysql.sock \
		-u root \
		--skip-password <<EOSQL

	ALTER USER 'root'@'localhost'
	IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

	CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
	IDENTIFIED BY '${MYSQL_PASSWORD}';

	GRANT ALL PRIVILEGES
	ON ${MYSQL_DATABASE}.*
	TO '${MYSQL_USER}'@'%';

	FLUSH PRIVILEGES;

EOSQL

	# Stop temporary MariaDB server.
	echo "Stopping temporary MariaDB..."

	mariadb-admin \
		--socket=/tmp/mysql.sock \
		-u root \
		-p"${MYSQL_ROOT_PASSWORD}" shutdown

	wait "$pid"
	echo "MariaDB initialization complete."
else
	echo "Existing MariaDB installation detected."

fi

echo "Starting MariaDB..."

# Replace shell process with MariaDB.
# mysqld becomes PID 1 so Docker can correctly manage signals.
exec mysqld --user=mysql
