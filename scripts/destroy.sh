#!/bin/bash
echo "[INFO] Cleaning up LocalStack deployment..."
export AWS_ENDPOINT_URL=http://localstack:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# Navigate to Terraform directory using absolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")/infra-tf"
echo "[DEBUG] Terraform directory: $TERRAFORM_DIR"
cd "$TERRAFORM_DIR"

terraform destroy -auto-approve
echo "[INFO] LocalStack deployment destroyed."