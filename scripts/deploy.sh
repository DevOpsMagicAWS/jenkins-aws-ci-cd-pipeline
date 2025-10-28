#!/bin/bash
echo "[INFO] Running LocalStack deployment..."

# Get LocalStack container IP
LOCALSTACK_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' localstack)
echo "[DEBUG] LocalStack IP: $LOCALSTACK_IP"

export AWS_ENDPOINT_URL=http://$LOCALSTACK_IP:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

echo "[DEBUG] AWS_ENDPOINT_URL: $AWS_ENDPOINT_URL"
echo "[DEBUG] Testing LocalStack connection..."
curl -f $AWS_ENDPOINT_URL/_localstack/health || echo "LocalStack not reachable"

cd infra-tf
terraform init
terraform apply -auto-approve
echo "[INFO] LocalStack deployment completed."