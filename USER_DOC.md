# User Documentation

## Overview

This project provides a small WordPress infrastructure composed of three services:

- **NGINX**: Handles HTTPS connections and acts as the entry point to the website.
- **WordPress + PHP-FPM**: Provides the website application.
- **MariaDB**: Stores WordPress data.

The services run in separate Docker containers and communicate through a private Docker network.

---

## Starting and Stopping the Project

### Start the project

From the repository root:

```bash
make
```

This will build the Docker images and start all services.

### Stop the project

```bash
make down
```

To completely remove containers:

```bash
make clean
```

---

## Accessing the Website

The website is available through HTTPS:

```
https://<login>.42.fr
```

The WordPress administration panel is available at:

```
https://<login>.42.fr/wp-admin
```

Use the WordPress administrator credentials created during setup to log in.

---

## Credentials Management

Credentials are stored using Docker secrets.

Secrets are automatically generated during setup and stored locally in the `secrets/` directory.

To view available secrets:

```bash
ls secrets/
```

Sensitive files should never be committed to the repository.

---

## Checking Service Status

To verify that all containers are running:

```bash
docker compose ps
```

Expected services:

- nginx
- wordpress
- mariadb

To view service logs:

```bash
docker compose logs <service_name>
```

Example:

```bash
docker compose logs nginx
```

---

## Persistent Data

The project uses Docker named volumes to preserve data:

- MariaDB database files
- WordPress website files

Data remains available after stopping and restarting the containers.
