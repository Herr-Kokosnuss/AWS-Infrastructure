# main instance aws
# resource "aws_instance" "web" {
#   ami                    = var.ami
#   instance_type          = "t2.micro"
#   key_name               = aws_key_pair.main_key.key_name
#   vpc_security_group_ids = [aws_security_group.alb.id]

#   tags = {
#     Name = "main-instance"
#   }
# }

# # static IP address for the instance
# resource "aws_eip" "ElasticIP" {
#   instance = aws_instance.web.id
# }

# S3 bucket with versioning enabled, AES256 encryption, and block public access.
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "terraform-state-8520" #should be unique
#   lifecycle {
#     prevent_destroy = false
#   }
# }

# resource "aws_s3_bucket_versioning" "enabled" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
#   bucket = aws_s3_bucket.terraform_state.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "public_access_block" {
#   bucket                  = aws_s3_bucket.terraform_state.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "terraform-state-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

#Define the launch template
resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = var.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.main_key.key_name // Add this line

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
    subnet_id                   = aws_subnet.public[0].id  # Use the first public subnet
  }

  #if no admin access in iam role, this needs to be here.
  iam_instance_profile {
    name = aws_iam_instance_profile.cloudwatch_agent_profile.name
  }

  user_data = base64encode(templatefile("userdata.sh", {
    efs_id = aws_efs_file_system.example.id
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "terraform-asg-example"
    }
  }
}
# Creating an autoscaling group
# resource "aws_autoscaling_group" "example" {
#   #launch_configuration = aws_launch_configuration.example.name
#   vpc_zone_identifier  = data.aws_subnets.default.ids

#   target_group_arns = [aws_lb_target_group.asg.arn]

#   health_check_type = "ELB"

#   min_size = 2
#   max_size = 2
#   tag {
#     key                 = "Name"
#     value               = "terraform-asg-example"
#     propagate_at_launch = true
#   }
# }
resource "aws_autoscaling_group" "example" {

  vpc_zone_identifier = aws_subnet.public[*].id  # Use all public subnets

  target_group_arns = [aws_lb_target_group.asg.arn]

  health_check_type = "ELB"

  min_size = 2
  max_size = 2
  desired_capacity = 2

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
}

# Retrieve the instances in the ASG to get IPs
data "aws_instances" "asg_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.example.name
  }

  instance_state_names = ["running"]

  depends_on = [aws_autoscaling_group.example]
}
#Amazon’s Elastic Load Balancer (ELB)
resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]
}

# create a target group for ASG
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200,301,302"
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

# Create EFS File System
resource "aws_efs_file_system" "example" {
  creation_token = "my-efs"
  encrypted      = true

  tags = {
    Name = "MyEFS"
  }
}

# Create EFS Mount Targets
resource "aws_efs_mount_target" "example" {
  count           = length(aws_subnet.private)
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.efs.id]
}
