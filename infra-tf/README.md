# Infrastructure as Code (Terraform)

This directory contains Terraform configuration files for deploying AWS infrastructure to LocalStack.

## Files Overview

### `main.tf`
**Purpose**: Main Terraform configuration with AWS provider and resources

**Resources Created**:
- `aws_s3_bucket.demo_bucket` - S3 bucket for demo purposes
- `random_id.id` - Random ID generator for unique resource naming

**Provider Configuration**:
- Configured for LocalStack compatibility
- Uses environment variables for endpoint URL
- Skip AWS credential validation for local testing

### `variables.tf`
**Purpose**: Input variables for Terraform configuration

**Variables**:
- `region` - AWS region (default: "us-east-1")

### `outputs.tf`
**Purpose**: Output values from Terraform deployment

**Outputs**:
- `bucket_name` - Name of the created S3 bucket
- `region_used` - AWS region used for deployment

### `backend.tf`
**Purpose**: Terraform backend configuration (currently disabled)

**Note**: S3 backend is commented out to avoid LocalStack authentication issues during testing.

## Usage

### Initialize Terraform
```bash
cd infra-tf
terraform init
```

### Plan Infrastructure
```bash
terraform plan
```

### Apply Infrastructure
```bash
terraform apply
```

### Destroy Infrastructure
```bash
terraform destroy
```

## Environment Variables

Required for LocalStack integration:

| Variable | Example | Description |
|----------|---------|-------------|
| `AWS_ENDPOINT_URL` | `http://localstack:4566` | LocalStack endpoint |
| `AWS_ACCESS_KEY_ID` | `test` | LocalStack credentials |
| `AWS_SECRET_ACCESS_KEY` | `test` | LocalStack credentials |
| `AWS_DEFAULT_REGION` | `us-east-1` | AWS region |

## LocalStack Integration

The configuration is optimized for LocalStack:
- `s3_use_path_style = true` - Required for LocalStack S3
- `skip_credentials_validation = true` - Bypass AWS credential checks
- `skip_metadata_api_check = true` - Skip AWS metadata API
- `skip_requesting_account_id = true` - Skip account ID validation

## Resources Created

When deployed, this creates:
1. **S3 Bucket**: `devops-demo-bucket-{random-hex}`
2. **Random ID**: 8-character hex string for unique naming

## Troubleshooting

**"Error configuring S3 Backend"**
- Backend is disabled for LocalStack compatibility
- Use local state for testing

**"InvalidAccessKeyId"**
- Ensure LocalStack is running and accessible
- Check AWS_ENDPOINT_URL environment variable

**"NoSuchBucket" errors**
- LocalStack S3 service may not be ready
- Wait for LocalStack health check to pass