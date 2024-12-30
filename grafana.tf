# Create IAM user for grafana
resource "aws_iam_user" "grafana_cloudwatch" {
  name = "grafana_cloudwatch"
  path = "/system/"

  tags = {
    Description = "IAM user for Grafana CloudWatch integration"
  }

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

  lifecycle {
    create_before_destroy = true
  }
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

# Add ECR policy to the existing CloudWatch agent role
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
