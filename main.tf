
resource "random_id" "rand" {
  byte_length = 4
}

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

  depends_on = [
    aws_s3_bucket_public_access_block.frontend
  ]

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

resource "aws_s3_object" "images" {
  for_each = fileset("frontend/images", "*")

  bucket = aws_s3_bucket.frontend.id
  key    = "images/${each.value}"
  source = "frontend/images/${each.value}"

  etag = filemd5("frontend/images/${each.value}")

  content_type = each.value == "dreamsquad-logo.svg" ? "image/svg+xml" : "image/jpeg"
}

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
    cidr_blocks   = ["0.0.0.0/0"]
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = -1
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_instance" "backend" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 3000:80 nginx
              EOF

  tags = {
    Name = "backend-container"
  }
}

resource "aws_s3_bucket" "routine_bucket" {
  bucket = "arthur-routine-${random_id.rand.hex}"
  force_destroy = true
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-${random_id.rand.hex}"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"
    Statement = [{

      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
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

resource "aws_lambda_function" "routine" {
  function_name = "daily-routine-${random_id.rand.hex}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename = "lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("lambda/lambda_function.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.routine_bucket.bucket
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily"  {
  schedule_expression = "cron(0 13 * * ? *)"
}
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule       = aws_cloudwatch_event_rule.daily.name
  target_id = "lambda"
  arn        = aws_lambda_function.routine.arn

  }

  resource "aws_lambda_permission" "allow_eventbridge" {
    statement_id = "AllowExecutionFromEventbridge"
    action       = "lambda:InvokeFunction"
    function_name   =  aws_lambda_function.routine.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.daily.arn
  }
