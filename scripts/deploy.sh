#!/bin/bash
set -e  # Exit on any error

echo "[INFO] Running LocalStack deployment..."

# Find LocalStack container
echo "[DEBUG] Looking for LocalStack container..."
docker ps | grep localstack || { echo "LocalStack container not found"; exit 1; }

# Get LocalStack container name (try multiple patterns)
LOCALSTACK_CONTAINER=$(docker ps --format "{{.Names}}" | grep -i localstack | head -1)
echo "[DEBUG] Found LocalStack container: $LOCALSTACK_CONTAINER"

if [ -z "$LOCALSTACK_CONTAINER" ]; then
    echo "[ERROR] No LocalStack container found"
    exit 1
fi

# Try different connection methods for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# Check if container is on devops-net network (docker-compose)
NETWORK_CHECK=$(docker inspect $LOCALSTACK_CONTAINER --format '{{range $net, $config := .NetworkSettings.Networks}}{{$net}}{{end}}' | grep -o devops-net || echo "")

if [ -n "$NETWORK_CHECK" ]; then
    # Use container name for docker-compose network
    export AWS_ENDPOINT_URL=http://$LOCALSTACK_CONTAINER:4566
    echo "[DEBUG] Using docker-compose LocalStack: $AWS_ENDPOINT_URL"
    
    echo "[DEBUG] Testing LocalStack connection..."
    curl -f $AWS_ENDPOINT_URL/_localstack/health || { echo "LocalStack not reachable"; exit 1; }
else
    echo "[DEBUG] Docker Desktop LocalStack found but not accessible from containers"
    echo "[DEBUG] Stopping Docker Desktop LocalStack..."
    docker stop $LOCALSTACK_CONTAINER || echo "Failed to stop existing LocalStack"
    
    echo "[DEBUG] Waiting for port to be released..."
    sleep 5
    
    echo "[DEBUG] Starting our own LocalStack container..."
    # Start LocalStack using docker-compose from /workspace/provision
    cd /workspace/provision
    docker-compose up -d localstack
    
    # Wait for LocalStack to be ready
    echo "[DEBUG] Waiting for LocalStack to start..."
    sleep 10
    
    export AWS_ENDPOINT_URL=http://localstack:4566
    echo "[DEBUG] Using our LocalStack: $AWS_ENDPOINT_URL"
    
    # Test connection with retries
    for i in {1..5}; do
        if curl -f $AWS_ENDPOINT_URL/_localstack/health; then
            echo "[DEBUG] LocalStack is ready"
            break
        else
            echo "[DEBUG] LocalStack not ready, waiting... ($i/5)"
            sleep 5
        fi
    done
    
    cd /workspace
fi

cd infra-tf
terraform init || { echo "Terraform init failed"; exit 1; }
terraform apply -auto-approve || { echo "Terraform apply failed"; exit 1; }
echo "[INFO] LocalStack deployment completed."