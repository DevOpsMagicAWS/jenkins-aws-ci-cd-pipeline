#!/bin/bash
echo "[INFO] Running LocalStack deployment..."
export AWS_ENDPOINT_URL=http://localstack:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

cd infra-tf
terraform init
terraform apply -auto-approve
echo "[INFO] LocalStack deployment completed."