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

#################################
# EC2 BACKEND COM O DOCKER 
#################################

resource "aws_instance" "backend" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.backend_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker start
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 3000:3000 nginx
              EOF

  tags = {
    Name = "bakend-container"
  }
}

#############################
# S3 BUCKET ROTINA
#############################

resource "aws_s3_bucket" "routine_bucket" {
  bucket = "arthur-routine-${random_id.rand.hex}"
}


#############################
# IAM ROLE LAMBDA
#############################

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-${random_id.rand.hex}"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"
    Statement = [{

      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Sercive = "lambda.amazonaws.com"
      }
    }]
    
    })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role         = aws_iam_role.lambda_role.name
  policy_arn   = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


