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

# configuring the launch configuration (discontinued oct 2024)
# resource "aws_launch_configuration" "example" {
#   image_id        = var.ami
#   instance_type   = "t2.micro"
#   security_groups = [aws_security_group.alb.id]
#   user_data       = file("userdata.sh")

#   lifecycle {
#     create_before_destroy = true
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
    security_groups             = [aws_security_group.alb.id]
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

  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]

  health_check_type = "ELB"

  min_size = 2
  max_size = 2
  #desired_capacity = 2

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
  count           = length(data.aws_subnets.default.ids)
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = data.aws_subnets.default.ids[count.index]
  security_groups = [aws_security_group.alb.id]
}

# Create an SNS topic for CloudWatch alarms
resource "aws_sns_topic" "asg_alarms" {
  name = "asg-alarms-topic"
}

# Create an SNS topic subscription for email notifications
resource "aws_sns_topic_subscription" "asg_alarms_email" {
  topic_arn = aws_sns_topic.asg_alarms.arn
  protocol  = "email"
  endpoint  = "ahmed.alsaeedi7890@gmail.com"
}

# CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "asg-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}

# CloudWatch Alarm for EFS Disk Usage
resource "aws_cloudwatch_metric_alarm" "efs_disk_usage" {
  alarm_name          = "efs-disk-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "PercentIOLimit"
  namespace           = "AWS/EFS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EFS disk usage"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn]

  dimensions = {
    FileSystemId = aws_efs_file_system.example.id
  }
}

# IAM role for EC2 instances to send metrics to CloudWatch 
#in case not adminstrator access.
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "cloudwatch-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach CloudWatch agent policy to the role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_agent_role.name
}

# Create an instance profile for the role
resource "aws_iam_instance_profile" "cloudwatch_agent_profile" {
  name = "cloudwatch-agent-profile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

# CloudWatch Alarm for Memory Usage
resource "aws_cloudwatch_metric_alarm" "memory_usage" {
  alarm_name          = "asg-memory-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CustomMetrics"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 memory usage"
  alarm_actions       = [aws_sns_topic.asg_alarms.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}

# Create IAM user for grafana
resource "aws_iam_user" "grafana_cloudwatch" {
  name = "grafana_cloudwatch"
  path = "/system/"

  tags = {
    Description = "IAM user for Grafana CloudWatch integration"
  }

  # Add this lifecycle block
  lifecycle {
    create_before_destroy = true
  }
}

# Update the IAM user policy for Grafana CloudWatch
resource "aws_iam_policy" "grafana_cloudwatch_policy" {
  name        = "grafana_cloudwatch_policy"
  path        = "/"
  description = "IAM policy for Grafana CloudWatch integration"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData",
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents",
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "grafana_cloudwatch_policy_attach" {
  user       = aws_iam_user.grafana_cloudwatch.name
  policy_arn = aws_iam_policy.grafana_cloudwatch_policy.arn
}

# Create access key for the user
resource "aws_iam_access_key" "grafana_cloudwatch" {
  user = aws_iam_user.grafana_cloudwatch.name

  # Add this lifecycle block
  lifecycle {
    create_before_destroy = true
  }
}
