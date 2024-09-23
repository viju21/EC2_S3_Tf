provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc"{
 cidr_block = "10.0.0.0/16"
 tags ={
    Name = "Test_vpc"
    Environment = "Dev"
 }
}
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
}
resource aws_internet_gateway "web_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        Name = "web_igw"
    }
}
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}


resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}


resource "aws_instance" "web_server" {
  ami           = "ami-0e86e20dae9224db8" #ubuntu ami
  instance_type        = "t2.micro"
  key_name             = "tf_key"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  tags = {
    Name        = "web_server"
    Environment = "Dev"
  }
}
resource "aws_security_group" "web_server_sg" {
  name_prefix = "web-server"
  vpc_id      = aws_vpc.my_vpc.id

  # Ingress rule for SSH (Restrict to your IP instead of 0.0.0.0/0 for better security)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.37.148.247/32"]  # Replace with your actual IP
  }

  # Ingress rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_s3_bucket" "my_test_bucket" {
  bucket = "my-test-bucket1a"

  tags = {
    Name        = "My test Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "my_test_bucket_public_access_block" {
  bucket = aws_s3_bucket.my_test_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create the IAM policy with additional actions for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name   = "ec2-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

# Define the IAM policy with updated actions
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListAllMyBuckets",   # Added action
      "s3:HeadBucket"          # Added action
    ]
    resources = [
      "arn:aws:s3:::my-test-bucket1a",        # Bucket ARN
      "arn:aws:s3:::my-test-bucket1a/*"       # Objects in the bucket
    ]
  }
}

# Create the IAM role for EC2
resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "ec2-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

# Define the IAM role trust policy for EC2 to assume the role
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Instance Profile for attaching the role to the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-s3-access-instance-profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ec2_s3_access_role_policy_attachment" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

#output
output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "aws_s3_bucket_name" {
    value = aws_s3_bucket.my_test_bucket.id
}


