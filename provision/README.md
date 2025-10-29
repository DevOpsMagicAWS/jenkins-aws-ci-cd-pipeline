# Provision Directory

This directory contains Docker configuration files for setting up the development environment with Jenkins and LocalStack.

## Files Overview

### `docker-compose.yml`
**Purpose**: Orchestrates Jenkins and LocalStack containers

**Services**:
- **jenkins**: Custom Jenkins container with Docker and Terraform CLI
- **localstack**: AWS services mock for local development

**Network**: `devops-net` - Allows containers to communicate by name

### `Dockerfile.jenkins`
**Purpose**: Custom Jenkins image with required tools

**Base Image**: `jenkins/jenkins:lts`

**Installed Tools**:
- Docker CLI (for building/running containers)
- Terraform CLI (for infrastructure deployment)
- Pre-configured Jenkins plugins
- Admin user setup (admin/admin123)

### `plugins.txt`
**Purpose**: List of Jenkins plugins to install automatically

**Key Plugins**:
- `workflow-aggregator` - Pipeline functionality
- `git` - Git SCM integration
- `docker-workflow` - Docker pipeline steps
- `pipeline-stage-view` - Visual pipeline stages

## Quick Start

### Start All Services
```bash
cd provision
docker compose up -d
```

### Stop All Services
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f jenkins
docker compose logs -f localstack
```

## Service Details

### Jenkins Container
- **Port**: 8080 (Web UI)
- **Port**: 50000 (Agent communication)
- **Credentials**: admin/admin123
- **Volume**: `jenkins_home` (persistent data)
- **Docker Socket**: Mounted for Docker-in-Docker

### LocalStack Container
- **Port**: 4566 (All AWS services)
- **Services**: S3, IAM
- **Persistence**: Enabled with local volume
- **Health Check**: Built-in endpoint monitoring

## Network Architecture

```
┌─────────────┐    devops-net    ┌─────────────┐
│   Jenkins   │◄────────────────►│ LocalStack  │
│   :8080     │                  │   :4566     │
└─────────────┘                  └─────────────┘
```

- Jenkins connects to LocalStack via `http://localstack:4566`
- Both containers share the `devops-net` Docker network
- No localhost dependencies within containers

## Volumes

### `jenkins_home`
- **Purpose**: Persistent Jenkins data
- **Contains**: Jobs, plugins, configurations, build history
- **Backup**: Important for preserving Jenkins state

### `localstack_data`
- **Purpose**: LocalStack persistence
- **Contains**: AWS resource state between restarts
- **Location**: `./localstack_data/`

## Environment Variables

### Jenkins
- `JAVA_OPTS`: JVM options for Jenkins
- `JENKINS_OPTS`: Jenkins-specific options

### LocalStack
- `SERVICES`: Enabled AWS services (s3,iam)
- `DEBUG`: Debug level (0=off, 1=on)
- `PERSISTENCE`: Enable state persistence (1=on)
- `AWS_*`: Default AWS configuration

## Health Checks

Both services include health checks:
- **Jenkins**: `curl -f http://localhost:8080/login`
- **LocalStack**: `curl -f http://localhost:4566/_localstack/health`

## Troubleshooting

**"Port already in use"**
- Stop existing Jenkins/LocalStack containers
- Check Docker Desktop for running containers

**"Permission denied" (Docker socket)**
- Ensure Docker daemon is running
- Check Docker socket permissions

**"Jenkins plugins failed to install"**
- Check internet connectivity
- Verify plugins.txt format

**"LocalStack not accessible"**
- Wait for health check to pass
- Check container logs for errors

## Development Workflow

1. **Start Environment**: `docker compose up -d`
2. **Access Jenkins**: http://localhost:8080
3. **Create Pipeline**: Point to your Git repository
4. **Run Pipeline**: Jenkins will use LocalStack automatically
5. **Stop Environment**: `docker compose down`