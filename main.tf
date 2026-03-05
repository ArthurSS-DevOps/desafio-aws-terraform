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
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "frontend/index.html"
  content_type = "text/html"
}

###################################
# SECURITY GROUP BACKEND DO PROJETO
###################################

resource "aws_security_group" "backend_sg" {
  name = "backend_sg-${random_id.rand.hex}"

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = {"0.0.0.0/0"}
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = 0
    cidr_blocks   = 0
  }
}

#####################################
# AMAZON LINUX AMI
#####################################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x84_64-gp2"]
  }
}

