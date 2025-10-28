output "bucket_name" {
    value = aws_s3_bucket.demo_bucket.bucket
}

output "region_used" {
    value = var.region
}