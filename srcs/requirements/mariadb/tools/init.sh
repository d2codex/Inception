#!/bin/bash

#Exit the script immediately if any command returns a non-zero (error) status.
set -e

# Create MariaDB runtime directory for Unix socket
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize MariaDB system tables if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB..."

	#Initialize database system tables
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
echo "Starting temporary MariaDB"
# temporary MariaDb - starts mariadb only for setup  since
# we cannot create users/databases if the server is not running
mysqld \
	--user=mysql \
	--skip-networking \
	--socket=/tmp/mysql.sock &

pid="$!"

# Wait until MariaDB is ready
# # Redirect stdout and stderr to /dev/null.
# # 2>&1 sends error output (fd 2) to the same place as normal output (fd 1).
until mariadb-admin \
	--socket=/tmp/mysql.sock \
	ping >/dev/null 2>&1; do

	sleep 1
done

echo "MariaDB temporary server is ready"

# Configure root password.
# must happen before running authenticated MariaDB commands
mariadb --socket=/tmp/mysql.sock <<EOSQL
ALTER USER 'root'@'localhost'
IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;

EOSQL

# Check if database exists
DB_EXISTS=$(mariadb \
	--socket=/tmp/mysql.sock \
	-u root \
	-p"${MYSQL_ROOT_PASSWORD}" \
	-N \
	-e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';")

if [ -z "$DB_EXISTS" ]; then

	echo "Creating database ${MYSQL_DATABASE}..."
	echo "Creating user ${MYSQL_USER}..."

	# Configure database, user, and permissions
	mariadb \
		--socket=/tmp/mysql.sock \
		-u root \
		-p"${MYSQL_ROOT_PASSWORD}" <<EOSQL

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

# Stop temporay MariaDB server
echo "Stopping temporary Mariadb..."
mariadb-admin \
	--socket=/tmp/mysql.sock \
	-u root \
	-p"${MYSQL_ROOT_PASSWORD}" shutdown
wait "$pid"

echo "Starting MariaDB..."

# Replace the shell process with MariaDB.
# This makes mysqld become PID 1 inside the container,
# allowing Docker to properly track the main process
# and handle signals such as SIGTERM for clean shutdown.
exec mysqld --user=mysql
