# Base image
FROM debian:bookworm

# Install dependencies
RUN apt-get update && \
	apt-get install -y \
	nginx \
	openssl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists*

# Remove Debian's default website configuration
# We only want our own HTTPS server configuration.
RUN rm -f /etc/nginx/sites-enabled/default

# Configuration
# Add our virtual host configuration.
# nginx.conf includes files from conf.d/*.conf automatically.
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Application setup
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Ports (documentaion only)
EXPOSE 443

# Startup
ENTRYPOINT ["/usr/local/bin/init.sh"]
