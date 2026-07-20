#!/bin/bash

set -e

# Generate TLS certificate if it does not exist

if [ ! -f /etc/nginx/ssl/server.crt ]; then
	echo "Generating TLS certificate..."

	mkdir -p /etc/nginx/ssl

	openssl req \
		-x509 \
		-nodes \
		-days 365 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/server.key \
		-out /etc/nginx/ssl/server.crt \
		-subj "/CN=$DOMAIN_NAME"

fi

echo "Starting nginx..."

exec nginx -g "daemon off;"
