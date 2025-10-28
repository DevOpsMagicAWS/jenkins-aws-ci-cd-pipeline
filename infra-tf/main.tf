provider "aws" {
    region = var.region
    
    # LocalStack configuration
    access_key = "test"
    secret_key = "test"
    s3_use_path_style = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id = true
    
    endpoints {
        s3 = "http://localhost:4566"
        iam = "http://localhost:4566"
        cloudformation = "http://localhost:4566"
    }
}

resource "aws_s3_bucket" "demo_bucket" {
    bucket = "devops-demo-bucket-${random_id.id.hex}"
}

resource "random_id" "id" {
    byte_length = 4
}