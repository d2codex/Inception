COMPOSE = docker compose
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR := $(HOME)/data
SECRETS_DIR := secrets

# ---------------------------------------------------------------------------- #
# colors                                                                       #
# ---------------------------------------------------------------------------- #

RESET   := \033[0m
RED     := \033[31m
GRN   := \033[32m
YEL  := \033[33m
BLU    := \033[34m
MAG := \033[35m

# ---------------------------------------------------------------------------- #
# utility target                                                               #
# ---------------------------------------------------------------------------- #

## Create required host directories for Docker volumes
create-dirs:
	@printf "$(BLU)Checking data directories...$(RESET)\n"

	@if [ ! -d $(DATA_DIR) ]; then \
		mkdir -p $(DATA_DIR); \
		printf "$(YEL)✓ Created$(RESET) %s/\n" "$(DATA_DIR)"; \
	fi

	@if [ ! -d $(DATA_DIR)/mariadb ]; then \
		mkdir -p $(DATA_DIR)/mariadb; \
		printf "$(YEL)✓ Created$(RESET) %s/mariadb/\n" "$(DATA_DIR)"; \
	fi

	@if [ ! -d $(DATA_DIR)/wordpress ]; then \
		mkdir -p $(DATA_DIR)/wordpress; \
		printf "$(YEL)✓ Created$(RESET) %s/wordpress/\n" "$(DATA_DIR)"; \
	fi

	@printf "$(GRN)Done.$(RESET)\n"
## Create Docker secret files if they do not already exist
create-secrets:
	@printf "$(BLU)Checking Docker secrets...$(RESET)\n"
	
	@if [ ! -d $(SECRETS_DIR) ]; then \
		mkdir -p $(SECRETS_DIR); \
		printf "$(YEL)✓ Created$(RESET) %s/\n" "$(SECRETS_DIR)"; \
	fi


	@if [ ! -f $(SECRETS_DIR)/db_password.txt ]; then \
		openssl rand -base64 32 > $(SECRETS_DIR)/db_password.txt; \
		printf "$(YEL)✓ Created$(RESET) %s/db_password.txt\n" "$(SECRETS_DIR)"; \
	else \
		printf "$(YEL)• Using existing$(RESET) %s/db_password.txt\n" "$(SECRETS_DIR)"; \
	fi

	@if [ ! -f $(SECRETS_DIR)/db_root_password.txt ]; then \
		openssl rand -base64 32 > $(SECRETS_DIR)/db_root_password.txt; \
		printf "$(YEL)✓ Created$(RESET) %s/db_root_password.txt\n" "$(SECRETS_DIR)"; \
	else \
		printf "$(YEL)• Using existing$(RESET) %s/db_root_password.txt\n" "$(SECRETS_DIR)"; \
	fi

	@if [ ! -f $(SECRETS_DIR)/wp_admin_password.txt ]; then \
		openssl rand -base64 32 > $(SECRETS_DIR)/wp_admin_password.txt; \
		printf "$(YEL)✓ Created$(RESET) %s/wp_admin_password.txt\n" "$(SECRETS_DIR)"; \
	else \
		printf "$(YEL)• Using existing$(RESET) %s/wp_admin_password.txt\n" "$(SECRETS_DIR)"; \
	fi

	@if [ ! -f $(SECRETS_DIR)/wp_user_password.txt ]; then \
		openssl rand -base64 32 > $(SECRETS_DIR)/wp_user_password.txt; \
		printf "$(YEL)✓ Created$(RESET) %s/wp_user_password.txt\n" "$(SECRETS_DIR)"; \
	else \
		printf "$(YEL)• Using existing$(RESET) %s/wp_user_password.txt\n" "$(SECRETS_DIR)"; \
	fi

	@printf "$(GRN)Done.$(RESET)\n"
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
up: create-dirs create-secrets
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
build-mariadb:
	$(COMPOSE) -f $(COMPOSE_FILE) build mariadb

## Start NGINX service only
up-nginx:
	$(COMPOSE) -f $(COMPOSE_FILE) up nginx

## Start WordPress service only
up-wordpress:
	$(COMPOSE) -f $(COMPOSE_FILE) up wordpress
## Start MariaDB service only
up-mariadb:
	$(COMPOSE) -f $(COMPOSE_FILE) up mariadb

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
	@$(COMPOSE) -f $(COMPOSE_FILE) down

## Remove containers, networks and volumes and generated files
fclean:
	@$(COMPOSE) -f $(COMPOSE_FILE) down -v

	@if [ -d $(DATA_DIR) ]; then \
		sudo rm -rf $(DATA_DIR); \
		printf "$(MAG)✓ Removed$(RESET) %s/\n" "$(DATA_DIR)"; \
	fi

	@if [ -d $(SECRETS_DIR) ]; then \
		rm -rf $(SECRETS_DIR); \
		printf "$(MAG)✓ Removed$(RESET) %s/\n" "$(SECRETS_DIR)"; \
	fi

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

.PHONY: create-dirs create-secrets all build up down restart build-ngix build-wordpress \
	build-mariadb logs logs-nginx logs-wordpress logs-mariadb shell-nginx shell-wordpress \
	shell-maraidb ps clean fclean re help up-mariadb up-nginx up-wordpress
