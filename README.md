# Task Manager Dockerized

A robust, containerized Task Management application built with **Flask**, **PostgreSQL**, **Redis**, and **Nginx**. This project demonstrates a production-ready Docker architecture with multi-stage builds, health checks, and secure reverse proxying.

## 🚀 Architecture Overview

- **Nginx**: Acts as a reverse proxy with SSL termination and serves static assets.
- **Flask App**: The core backend logic (Python 3.12) running via Gunicorn.
- **PostgreSQL**: Persistent storage for tasks.
- **Redis**: Caching layer to speed up GET requests.
- **Docker Compose**: Orchestrates all services into a unified network.

## 🛠 Docker Configuration

### Dockerfile (Multi-stage)
The `Dockerfile` uses a two-stage build to minimize the final image size:
1.  **Builder Stage**: Installs build dependencies (gcc, musl-dev) and compiles Python requirements.
2.  **Runtime Stage**: A lean Alpine-based image that only contains the necessary runtime libraries and the pre-installed Python packages from the builder stage.
3.  **Security**: Runs as a non-privileged `flaskuser`.
4.  **Healthcheck**: Includes a built-in health check using `wget` to monitor the app's responsiveness.

### Docker Compose
The `docker-compose.yaml` file defines the following:
- **Networks**: A dedicated `flask_network` for secure inter-service communication.
- **Volumes**: Persistent volumes for PostgreSQL and Redis data.
- **Dependencies**: Explicit `depends_on` with `service_healthy` conditions to ensure services start in the correct order.
- **Resource Limits**: CPU and memory limits are applied to the Flask and PostgreSQL containers for stability.

## 🚦 Getting Started

### 1. Prerequisites
- Docker and Docker Compose installed.
- (Optional) OpenSSL for certificate generation.

### 2. Setup Environment
Create a `.env` file in the root directory (referencing `docker-compose.yaml` variables):
```env
POSTGRES_USER=appuser
POSTGRES_PASSWORD=secret
POSTGRES_DB=taskmanager
POSTGRES_HOST=postgres
REDIS_HOST=redis
REDIS_PORT=6379
NGINX_HTTP=80
NGINX_HTTPS=443
```

### 3. Generate SSL Certificates
Run the provided script to generate self-signed certificates for Nginx:
```bash
cd ssl
chmod +x generate_ssl.sh
./generate_ssl.sh
cd ..
```

### 4. Build and Run
Launch the entire stack with a single command:
```bash
docker-compose up --build
```

The application will be available at:
- **HTTPS**: `https://localhost` (Primary)
- **HTTP**: `http://localhost` (Redirects to HTTPS)

## 🔍 API Endpoints

- `GET /`: Interactive Dashboard.
- `GET /api/health`: Health status of the app, DB, and Redis.
- `GET /api/tasks`: List all tasks (cached via Redis).
- `POST /api/tasks`: Add a new task.
- `PATCH /api/tasks/<id>/done`: Mark a task as completed.

## 🛡 Security Features
- **SSL/TLS**: Nginx is configured with modern protocols (TLSv1.2/1.3).
- **Rate Limiting**: Nginx limits API requests to 20 per second.
- **Non-Root User**: The Flask application runs as a restricted user inside the container.
- **Security Headers**: Includes `X-Frame-Options` and `X-Content-Type-Options`.
