# Base image
FROM debian:bookworm

# Environment variables
# noninteractive prevents pkg installation from asking questions
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
# removes downloaded .deb package archives
# remove apt cache
# after this inside the image we have:
# /usr/sbin/mysqld
# /etc/mysql/
RUN apt-get update && apt upgrade -y  && \
    apt-get install -y mariadb-server && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* \
	rm -rf /var/lib/mysql/*

# Configuration
# replace the default server configuration
# 50-server.cnf config file gets installed when we install mariadb
# we then override our config to this file
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Application setup
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Volumes (optional)

# Ports (does not actually expose, documentaion only)
EXPOSE 3306

# Startup
# ENTRYPOINT vs CMD
# ENTRYPOINT defines what always runs when the container starts
# CMD provids a default command
ENTRYPOINT ["/usr/local/bin/init.sh"]
