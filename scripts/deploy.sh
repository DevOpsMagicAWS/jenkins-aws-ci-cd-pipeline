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

# Get LocalStack container IP
LOCALSTACK_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $LOCALSTACK_CONTAINER)
echo "[DEBUG] LocalStack IP: $LOCALSTACK_IP"

export AWS_ENDPOINT_URL=http://$LOCALSTACK_IP:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

echo "[DEBUG] AWS_ENDPOINT_URL: $AWS_ENDPOINT_URL"
echo "[DEBUG] Testing LocalStack connection..."
curl -f $AWS_ENDPOINT_URL/_localstack/health || { echo "LocalStack not reachable"; exit 1; }

cd infra-tf
terraform init || { echo "Terraform init failed"; exit 1; }
terraform apply -auto-approve || { echo "Terraform apply failed"; exit 1; }
echo "[INFO] LocalStack deployment completed."