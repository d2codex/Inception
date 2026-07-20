#!/bin/bash

# Exit the script immediately if any command returns a non-zero (error) status.
set -e

# Create MariaDB runtime directory for Unix socket
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize MariaDB system tables if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB..."

	# Initialize database system tables
	mariadb-install-db \
		--user=mysql \
		--datadir=/var/lib/mysql
fi

# Read database passwords from Docker secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

echo "MYSQL_DATABASE=${MYSQL_DATABASE}"
echo "MYSQL_USER=${MYSQL_USER}"

# Start temporary MariaDB server for initial configuration
echo "Starting temporary MariaDB..."

# Temporary MariaDB instance:
# - Used only during first initialization
# - Uses Unix socket communication only
# - Does not expose TCP networking
mysqld \
	--user=mysql \
	--skip-networking \
	--socket=/tmp/mysql.sock &

pid="$!"

# Wait until temporary MariaDB server is ready
# Force socket protocol because MYSQL_HOST=mariadb is used by
# WordPress later, but is not available during this local setup phase.
until mariadb-admin \
	--protocol=socket \
	--socket=/tmp/mysql.sock \
	ping >/dev/null 2>&1; do

	sleep 1
done

echo "MariaDB temporary server is ready"

# Check if database already exists
DB_EXISTS=$(mariadb \
	--protocol=socket \
	--socket=/tmp/mysql.sock \
	-N \
	-e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';")

if [ -z "$DB_EXISTS" ]; then

	echo "Creating database ${MYSQL_DATABASE}..."
	echo "Creating user ${MYSQL_USER}..."

	# Configure database, user, and permissions
	mariadb \
		--protocol=socket \
		--socket=/tmp/mysql.sock <<EOSQL

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

else

	echo "Database ${MYSQL_DATABASE} already exists."

fi

# Stop temporary MariaDB server
echo "Stopping temporary MariaDB..."

mariadb-admin \
	--protocol=socket \
	--socket=/tmp/mysql.sock \
	-u root \
	-p"${MYSQL_ROOT_PASSWORD}" shutdown

wait "$pid"

echo "Starting MariaDB..."

# Replace shell process with MariaDB.
# This makes mysqld become PID 1 inside the container,
# allowing Docker to properly track the process
# and handle signals such as SIGTERM for clean shutdown.
exec mysqld --user=mysql
