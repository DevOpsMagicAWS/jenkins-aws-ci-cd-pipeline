# Disable remote backend for LocalStack testing
# terraform {
#   backend "s3" {
#     bucket = "devops-demo-bucket-bcea1aa2"
#     key    = "terraform/state.tfstate"
#     region = "us-east-1"
#     endpoints = {
#       s3 = "http://localstack:4566"
#     }
#     skip_credentials_validation = true
#     skip_metadata_api_check = true
#     force_path_style = true
#   }
# }