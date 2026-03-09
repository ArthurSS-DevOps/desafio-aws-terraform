output "frontend_url"{
    value = aws_s3_bucket.frontend.website_endpoint
}

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}
