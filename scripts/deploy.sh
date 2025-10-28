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
else
    # For Docker Desktop extension, use localhost
    export AWS_ENDPOINT_URL=http://localhost:4566
    echo "[DEBUG] Using Docker Desktop LocalStack: $AWS_ENDPOINT_URL"
fi

echo "[DEBUG] Testing LocalStack connection..."
curl -f $AWS_ENDPOINT_URL/_localstack/health || { echo "LocalStack not reachable"; exit 1; }

cd infra-tf
terraform init || { echo "Terraform init failed"; exit 1; }
terraform apply -auto-approve || { echo "Terraform apply failed"; exit 1; }
echo "[INFO] LocalStack deployment completed."