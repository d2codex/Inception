COMPOSE = docker compose
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR := /home/diade-so/data

# ---------------------------------------------------------------------------- #
# utility target                                                               #
# ---------------------------------------------------------------------------- #

## Create required host directories for Docker volumes
create-dirs:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress

# ---------------------------------------------------------------------------- #
# default                                                                      #
# ---------------------------------------------------------------------------- #

## Start the default local development stack
all: up

# ---------------------------------------------------------------------------- #
# lifecycle                                                                    #
# ---------------------------------------------------------------------------- #

## Build Docker images
build:
	$(COMPOSE) -f $(COMPOSE_FILE) build

## Build (if needed) and start the project
up: create-dirs
	$(COMPOSE) -f $(COMPOSE_FILE) up --build

## Stop and remove containers and networks
down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

## Restart containers
restart:
	$(COMPOSE) -f $(COMPOSE_FILE) restart

# ---------------------------------------------------------------------------- #
# individual services                                                          #
# ---------------------------------------------------------------------------- #

## Build NGINX image
build-nginx:
	$(COMPOSE) -f $(COMPOSE_FILE) build nginx

## Build WordPress image
build-wordpress:
	$(COMPOSE) -f $(COMPOSE_FILE) build wordpress

## Build MariaDB image
build-wordpress:
	$(COMPOSE) -f $(COMPOSE_FILE) build mariadb

# ---------------------------------------------------------------------------- #
# logs                                                                         #
# ---------------------------------------------------------------------------- #

## Follow logs from all containers
logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f

## Follow NGINX logs
logs-nginx:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f nginx

## Follow WordPress logs
logs-wordpress:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f wordpress

## Follow MariaDB logs
logs-mariadb:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f mariadb

# ---------------------------------------------------------------------------- #
# shells                                                                       #
# ---------------------------------------------------------------------------- #

## Open a shell in NGINX container
shell-nginx:
	$(COMPOSE) -f $(COMPOSE_FILE) exec nginx bash

## Open a shell in WordPress container
shell-wordpress:
	$(COMPOSE) -f $(COMPOSE_FILE) exec wordpress bash

## Open a shell in MariaDB container
shell-mariadb:
	$(COMPOSE) -f $(COMPOSE_FILE) exec mariadb bash

# ---------------------------------------------------------------------------- #
# status                                                                       #
# ---------------------------------------------------------------------------- #

## Show container status
ps:
	$(COMPOSE) -f $(COMPOSE_FILE) ps

# ---------------------------------------------------------------------------- #
# cleanup                                                                      #
# ---------------------------------------------------------------------------- #

## Remove containers and networks
clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down

## Remove containers, networks and volumes
fclean:
	$(COMPOSE) -f $(COMPOSE_FILE) down -v

## Rebuild and restart the project
re:
	$(MAKE) down
	$(MAKE) build
	$(MAKE) up

# ---------------------------------------------------------------------------- #
# magic help                                                                   #
# ---------------------------------------------------------------------------- #

# adapted from https://gitlab.com/depressiveRobot/make-help/blob/master/help.mk (MIT License)
help:
	@printf "\nAvailable targets:\n\n"
	@awk -F: '/^[a-zA-Z\-_0-9%\\ ]+:/ { \
			helpMessage = match(lastLine, /^## (.*)/); \
			if (helpMessage) { \
					helpCommand = $$1; \
					helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
					printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
			} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u
	@printf "\n"

.PHONY: all help up down build logs ps restart clean fclean re
