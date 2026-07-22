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

## Building and Running

The project is managed through the provided `Makefile`.

To view all available commands:

```bash
make help
```

### Project Lifecycle

| Command | Description |
|---------|-------------|
| `make` | Create required directories and secrets, build the images, and start the infrastructure. |
| `make build` | Build all Docker images. |
| `make up` | Start all services (building images if necessary). |
| `make down` | Stop and remove containers and networks. |
| `make restart` | Restart all running containers. |
| `make re` | Rebuild and restart the project. |
| `make clean` | Stop and remove containers and networks. |
| `make fclean` | Remove containers, networks, volumes, generated secrets, and persistent data. |

> During the initial setup, the Makefile automatically creates the required host directories for Docker volumes and generates Docker secrets if they do not already exist.

### Monitoring

| Command | Description |
|---------|-------------|
| `make ps` | Display the status of all containers. |
| `make logs` | Follow logs from all services. |
| `make logs-nginx` | Follow NGINX logs. |
| `make logs-wordpress` | Follow WordPress logs. |
| `make logs-mariadb` | Follow MariaDB logs. |

### Access Containers

| Command | Description |
|---------|-------------|
| `make shell-nginx` | Open a shell inside the NGINX container. |
| `make shell-wordpress` | Open a shell inside the WordPress container. |
| `make shell-mariadb` | Open a shell inside the MariaDB container. |

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
## Inspecting the MariaDB Database

### Access the MariaDB container

```bash
docker exec -it srcs-mariadb-1 sh
```

### Connect to MariaDB

```bash
mariadb -u root -p
```

When prompted, enter the password stored in:

```text
secrets/db_root_password.txt
```

### Inspect the WordPress database

List all databases:

```sql
SHOW DATABASES;
```

Select the WordPress database:

```sql
USE wordpress;
```

List all tables:

```sql
SHOW TABLES;
```

Display the WordPress users:

```sql
SELECT ID, user_login, user_email FROM wp_users;
```

These commands verify that the database was successfully created, the WordPress schema has been initialized, and the configured users exist.

## Network

The services communicate through a dedicated Docker network created by Docker Compose.

The network allows:

- NGINX to communicate with WordPress.
- WordPress to communicate with MariaDB.

Containers are isolated from external access except through NGINX on port 443.
