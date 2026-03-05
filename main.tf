############################
# RANDOM PARA NOMES ÚNICOS
############################

resource "random_id" "rand" {
  byte_length = 4
}

############################
# S3 FRONTEND
############################

resource "aws_s3_bucket" "frontend" {
  bucket = "arthur-frontend-${random_id.rand.hex}"
}

resource "aws_s3_bucket_website_configuration" "frontend_config" {
  buket = aws_s3_bucket.frontend.id

  index_document {
    sufix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
}
