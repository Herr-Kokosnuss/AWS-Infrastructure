# main instance aws
resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.main_key.key_name
  vpc_security_group_ids = [aws_security_group.alb.id]

  tags = {
    Name = "main-instance"
  }
}

# static IP address for the instance
resource "aws_eip" "ElasticIP" {
  instance = aws_instance.web.id
}

# S3 bucket with versioning enabled, AES256 encryption, and block public access.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-8520"
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "terraform-state-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# configuring the launch configuration
resource "aws_launch_configuration" "example" {
  image_id        = var.ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.alb.id]
  user_data       = file("userdata.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# Creating an autoscaling group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]

  health_check_type = "ELB"

  min_size = 2
  max_size = 4
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

#Amazon’s Elastic Load Balancer (ELB)
resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

# create a target group for ASG
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# define a listener for the above Application Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

