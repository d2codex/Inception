#!/bin/bash

# this script is responsible for:
#	reading secrets
#	initializing the databse if needed
#	creating users/databases
#	starting the MariaDB daemon

#Exit the script immediately if any command returns a non-zero (error) status.
set -e

# Read database passwords from Docker secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Check if MariaDB has already been initializing
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB database..."

	#Initialize database system tables
	mariadb-install-db \
		--user=mysql \
		--datadir=/var/lib/mysql

	# temporary MariaDb - starts mariadb only for setup  since
	# we cannot create users/databases if the server is not running
	mysqld --skip-networking --socket=/tmp/mysql.sock &
	pid="$!"

	# Wait until MariaDB is ready
	until mariadb-admin --socket=/tmp/mysql.sock ping >/dev/null 2>&1
	do
		sleep 1
	done

	# Configure database, user, and permissions
	mariadb --socket=/tmp/mysql.sock << EOSQL
		ALTER USER 'root'@'localhost'
		IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
		IDENTIFIED BY '${MYSQL_PASSWORD}';

		GRANT ALL PRIVILEGES
		ON ${MYSQL_DATABASE}.*
		TO '${MYSQL_USER}'@'%';

		FLUSH PRIVILEDGES;
EOSQL

	# Stop temporay MariaDB server
	mariadb-admin \
		--socket=/tmp/mysql.sock \
		-u root \
		-p"${MYSQL_ROOT_PASSWORD" shutdown
	wait "$pid"
fi

echo "Starting MariaDB..."

# Replace the current shell process with the command passed as arguments.
# This makes the application (mysqld) become PID 1 inside the container,
# allowing Docker to properly track the main process and handle signals
# such as SIGTERM for clean shutdown.
exec "$@"
