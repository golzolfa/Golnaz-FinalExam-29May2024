provider "aws" {
  region = "us-west-2"
}

# Create an S3 Bucket
resource "aws_s3_bucket" "Golnaz_S3Bucket" {
  bucket = "golnaz-s3-bucket"
}

# Create an IAM Role
resource "aws_iam_role" "Golnaz_IAMRole" {
  name = "golnaz-iam-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Create an IAM Policy
resource "aws_iam_policy" "Golnaz_IAMPolicy" {
  name        = "golnaz-iam-policy"
  description = "Sample IAM policy for Golnaz IAM role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : aws_s3_bucket.Golnaz_S3Bucket.arn
      }
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "Golnaz_IAMRolePolicyAttachment" {
  role       = aws_iam_role.Golnaz_IAMRole.name
  policy_arn = aws_iam_policy.Golnaz_IAMPolicy.arn
}

# Create a Security Group
resource "aws_security_group" "Golnaz_SecurityGroup" {
  name        = "golnaz-security-group"
  description = "Security group with port 3306 open"
  vpc_id      = "vpc-01924659a82c51f0d"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an RDS Instance
resource "aws_db_instance" "Golnaz_RDSInstance" {
  identifier             = "golnaz-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro" # Change instance class to a supported one
  username               = "admin"
  password               = "Admin1234"
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.Golnaz_SecurityGroup.id]
}

# Create a KMS Key
resource "aws_kms_key" "Golnaz_KMSKey" {
  description             = "Golnaz KMS Key"
  deletion_window_in_days = 30
  tags = {
    Name = "golnaz-kms-key"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "Golnaz_ALB" {
  name               = "golnaz-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Golnaz_SecurityGroup.id]
  subnets            = ["subnet-0c1e1edc2de9052f1", "subnet-0d2c5652bb5f185bd"]
}

# Create a Launch Configuration
resource "aws_launch_configuration" "example" {
  name          = "example-launch-configuration"
  image_id      = "ami-0eb9d67c52f5c80e5"
  instance_type = "t2.micro"
}

# Create an AutoScaling Group
resource "aws_autoscaling_group" "Golnaz_ASG" {
  name                      = "golnaz-asg"
  launch_configuration      = aws_launch_configuration.example.id
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  vpc_zone_identifier       = ["subnet-0c1e1edc2de9052f1", "subnet-0d2c5652bb5f185bd"]
  health_check_type         = "EC2"
  health_check_grace_period = 300
}

# Create a Glue Job
resource "aws_glue_job" "Golnaz_GlueJob" {
  name     = "golnaz-glue-job"
  role_arn = aws_iam_role.Golnaz_IAMRole.arn
  command {
    name            = "glueetl"
    script_location = "s3://golnaz-s3-bucket/sample_script.py"
  }
}
