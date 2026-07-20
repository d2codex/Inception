# Base image
FROM debian:bookworm

# Install dependencies
RUN apt-get update && \
	apt-get install -y \
	nginx \
	openssl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists*

# Configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Application setup
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Ports (documentaion only)
EXPOSE 443

# Startup
ENTRYPOINT ["/usr/local/bin/init.sh"]
