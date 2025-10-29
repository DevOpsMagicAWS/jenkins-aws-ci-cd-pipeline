# Scripts Directory

This directory contains deployment and utility scripts for the Jenkins CI/CD pipeline.

## Scripts Overview

### `deploy.sh`
**Purpose**: Deploys infrastructure to LocalStack using Terraform

**Key Features**:
- **Smart LocalStack Detection**: Automatically detects and manages LocalStack containers
- **Multi-Environment Support**: Handles Docker Compose and Docker Desktop LocalStack
- **Network-Aware**: Uses appropriate connection methods based on container networking
- **Robust Error Handling**: Fails fast with descriptive error messages
- **Path Resolution**: Works from any directory using absolute paths

**Usage**:
```bash
bash scripts/deploy.sh
```

**What it does**:
1. Detects existing LocalStack containers
2. Starts LocalStack if needed (handles port conflicts)
3. Tests LocalStack connectivity with health checks
4. Runs `terraform init` and `terraform apply`
5. Creates AWS resources (S3 bucket, IAM resources)

### `destroy.sh`
**Purpose**: Destroys infrastructure created by deploy.sh

**Usage**:
```bash
bash scripts/destroy.sh
```

**What it does**:
1. Connects to LocalStack using standard endpoint
2. Runs `terraform destroy` to remove all resources
3. Cleans up AWS resources from LocalStack

## Environment Variables

The scripts use these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `AWS_ENDPOINT_URL` | `http://localstack:4566` | LocalStack endpoint |
| `AWS_ACCESS_KEY_ID` | `test` | LocalStack test credentials |
| `AWS_SECRET_ACCESS_KEY` | `test` | LocalStack test credentials |
| `AWS_DEFAULT_REGION` | `us-east-1` | AWS region for resources |

## LocalStack Detection Logic

The `deploy.sh` script handles three scenarios:

### 1. Docker Compose LocalStack (Preferred)
- **Detection**: Container on `devops-net` network
- **Connection**: Uses container name (`http://localstack:4566`)
- **Action**: Uses existing container directly

### 2. Docker Desktop LocalStack Extension
- **Detection**: LocalStack container not on `devops-net`
- **Connection**: Not accessible from Jenkins container
- **Action**: Stops extension, starts our own LocalStack

### 3. No LocalStack Running
- **Detection**: No LocalStack containers found
- **Action**: Starts new LocalStack using docker-compose

## Troubleshooting

### Common Issues

**"LocalStack container not found"**
- Ensure LocalStack is running or let script start it automatically
- Check Docker Desktop LocalStack extension status

**"No such file or directory"**
- Scripts use absolute path resolution
- Ensure you're running from project root or scripts work from any location

**"Port 4566 already in use"**
- Script automatically handles port conflicts
- Stops conflicting LocalStack containers before starting new ones

**"Terraform init failed"**
- Check network connectivity to LocalStack
- Verify LocalStack health endpoint responds
- Ensure Terraform files exist in `infra-tf/` directory

### Debug Mode

Add debug output by setting:
```bash
set -x  # Add to top of script for verbose output
```

## Dependencies

- **Docker**: Container management
- **Terraform**: Infrastructure as Code
- **curl**: Health checks and API testing
- **LocalStack**: AWS service mocking

## Integration with Jenkins

These scripts are called from the Jenkins pipeline (`jenkinsfile`):

1. **Deploy Stage**: Calls `deploy.sh`
2. **Destroy Stage**: Calls `destroy.sh` (optional, parameter-controlled)
3. **Post Actions**: Cleanup containers and workspace

## Best Practices

- **Always run deploy.sh before destroy.sh**
- **Check LocalStack health before running Terraform**
- **Use absolute paths for reliable execution**
- **Handle errors gracefully with proper exit codes**
- **Provide verbose logging for debugging**