# Developer Documentation

## Prerequisites

Before setting up the project, ensure the following tools are installed:

- Docker
- Docker Compose
- Make

The project must be run inside a virtual machine as required by the Inception subject.

---

## Project Setup

Clone the repository:

```bash
git clone <repository_url>
cd Inception
```

The project structure contains:

- `srcs/` - Docker Compose configuration and service requirements.
- `secrets/` - Docker secrets generated during setup.
- `Makefile` - Commands used to build and manage the infrastructure.

---

## Configuration

Environment variables are stored in:

```
srcs/.env
```

The required configuration includes:

```env
DOMAIN_NAME=<login>.42.fr

MYSQL_DATABASE=<database_name>
MYSQL_USER=<database_user>

WP_TITLE=<website_title>
WP_ADMIN_USER=<administrator_username>
WP_ADMIN_EMAIL=<administrator_email>
WP_USER=<wordpress_username>
WP_USER_EMAIL=<wordpress_user_email>
```

Passwords and sensitive information are handled through Docker secrets.

Secrets are generated automatically and stored in:

```
secrets/
```

Each secret is stored in a separate file to avoid exposing credentials in environment variables or the repository.

---

## Building and Launching

Build and start the infrastructure:

```bash
make
```

This command:

1. Creates required directories.
2. Generates secrets.
3. Builds Docker images.
4. Starts the containers using Docker Compose.

To rebuild images:

```bash
make build
```

To start existing containers:

```bash
make up
```

To stop the infrastructure:

```bash
make down
```

---

## Container Management

View running containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs <service_name>
```

Example:

```bash
docker compose logs nginx
```

Access a running container:

```bash
docker exec -it <container_name> sh
```

---

## Volume Management

The project uses Docker named volumes for persistent storage.

The volumes store:

| Volume | Purpose | Container Path |
|--------|---------|----------------|
| MariaDB volume | Database files | `/var/lib/mysql` |
| WordPress volume | Website files | `/var/www/html` |

The volume data is stored on the host machine:

```
/home/<login>/data/
```

Stopping or recreating containers does not remove this data.

To list volumes:

```bash
docker volume ls
```

To inspect a volume:

```bash
docker volume inspect <volume_name>
```

---

## Network

The services communicate through a dedicated Docker network created by Docker Compose.

The network allows:

- NGINX to communicate with WordPress.
- WordPress to communicate with MariaDB.

Containers are isolated from external access except through NGINX on port 443.

---

## Cleanup

Remove containers:

```bash
make clean
```

Remove all Docker resources created by the project:

```bash
make fclean
```

Rebuild everything from scratch:

```bash
make re
```
